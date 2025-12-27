# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "requests",
# ]
# ///
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

import requests

DUMMY_HASH = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="


# -------------------------
# Locate package-overrides.nix (relative resolution)
# -------------------------

def find_nearest_file_upwards(start_dir: Path, filename: str) -> Path | None:
    d = start_dir.resolve()
    for parent in (d, *d.parents):
        candidate = parent / filename
        if candidate.is_file():
            return candidate
    return None


def find_first_file_downwards(start_dir: Path, filename: str) -> Path | None:
    for p in start_dir.resolve().rglob(filename):
        if p.is_file():
            return p
    return None


def locate_package_overrides(script_path: Path) -> Path:
    here = script_path.resolve().parent

    p = find_nearest_file_upwards(here, "package-overrides.nix")
    if p:
        return p

    for base in [script_path.resolve().parents[1], Path.cwd()]:
        p = find_first_file_downwards(base, "package-overrides.nix")
        if p:
            return p

    raise RuntimeError(
        "Could not find package-overrides.nix (searched upwards from script dir and downwards from likely roots)."
    )


def infer_config_name_from_overrides_path(overrides_path: Path) -> str | None:
    """
    If overrides is at: .../machines/<name>/package-overrides.nix
    return <name>.
    """
    parts = overrides_path.resolve().parts
    for i, p in enumerate(parts):
        if p == "machines" and i + 1 < len(parts):
            return parts[i + 1]
    return None


# -------------------------
# Nix attr path helpers
# -------------------------

def nix_attr_segment(name: str) -> str:
    """
    Safe flake attribute segment.
    - bare identifiers stay bare
    - names like 'ollama-rocm' get quoted: "ollama-rocm"
    """
    if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", name):
        return name
    escaped = name.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def replace_one_dummy(text: str, new_hash: str) -> str:
    if DUMMY_HASH not in text:
        raise RuntimeError("No dummy hash found to replace.")
    return text.replace(DUMMY_HASH, new_hash, 1)


# -------------------------
# GitHub helpers
# -------------------------

def get_latest_github_release(owner: str, repo: str, prefix: str = "") -> str | None:
    url = f"https://api.github.com/repos/{owner}/{repo}/releases"
    try:
        r = requests.get(url, timeout=30)
        r.raise_for_status()
        releases = r.json()
    except Exception as e:
        print(f"Failed to fetch releases for {owner}/{repo}: {e}")
        return None

    max_ver = 0
    for rel in releases:
        tag = rel.get("tag_name", "")
        if not tag.startswith(prefix):
            continue
        try:
            ver = int(tag[len(prefix):])
        except ValueError:
            continue
        max_ver = max(max_ver, ver)

    return str(max_ver) if max_ver else None


def _semver_tuple(v: str) -> tuple[int, int, int] | None:
    m = re.fullmatch(r"(\d+)\.(\d+)\.(\d+)", v.strip())
    if not m:
        return None
    return (int(m.group(1)), int(m.group(2)), int(m.group(3)))


def get_latest_ollama_tag() -> str | None:
    """
    Ollama tags: vX.Y.Z
    Returns X.Y.Z (no leading v).
    """
    url = "https://api.github.com/repos/ollama/ollama/releases"
    try:
        r = requests.get(url, timeout=30)
        r.raise_for_status()
        releases = r.json()
    except Exception as e:
        print(f"Failed to fetch releases for ollama/ollama: {e}")
        return None

    best_ver = None
    best_t = None

    for rel in releases:
        tag = rel.get("tag_name", "")
        if not tag.startswith("v"):
            continue
        ver = tag[1:]
        t = _semver_tuple(ver)
        if t is None:
            continue
        if best_t is None or t > best_t:
            best_t = t
            best_ver = ver

    return best_ver


# -------------------------
# Updaters (edit Nix content)
# -------------------------

def update_llama_cpp(content: str) -> tuple[str, bool]:
    print("\n--- Checking llama-cpp ---")
    version_pattern = re.compile(
        r'(llama-cpp\s*=\s*.*?version\s*=\s*")(\d+)(";)', re.DOTALL
    )
    m = version_pattern.search(content)
    if not m:
        print("Could not find llama-cpp version definition.")
        return content, False

    current_ver = m.group(2)
    latest_ver = get_latest_github_release("ggml-org", "llama.cpp", "b")
    if not latest_ver:
        return content, False

    print(f"Current: {current_ver}, Latest: {latest_ver}")
    if int(latest_ver) <= int(current_ver):
        print("Already up to date.")
        return content, False

    print(f"Updating llama-cpp to {latest_ver}...")
    new_content = version_pattern.sub(rf"\g<1>{latest_ver}\g<3>", content)

    # Replace first hash after version with dummy
    ver_end = m.end()
    hash_pattern = re.compile(r'(hash\s*=\s*")(sha256-.*?|)";')
    hm = hash_pattern.search(new_content, pos=ver_end)
    if not hm:
        print("Could not find hash field for llama-cpp.")
        return content, False

    new_content = new_content[:hm.start(2)] + DUMMY_HASH + new_content[hm.end(2):]
    return new_content, True


def update_llama_swap(content: str) -> tuple[str, bool]:
    print("\n--- Checking llama-swap ---")
    url_pattern = re.compile(
        r"(https://github\.com/mostlygeek/llama-swap/releases/download/v)(\d+)"
        r"(/llama-swap_)(\d+)(_linux_amd64\.tar\.gz)"
    )
    m = url_pattern.search(content)
    if not m:
        print("Could not find llama-swap URL definition.")
        return content, False

    current_ver = m.group(2)
    if m.group(4) != current_ver:
        print(f"Warning: Inconsistent versions in URL: {current_ver} vs {m.group(4)}")

    latest_ver = get_latest_github_release("mostlygeek", "llama-swap", "v")
    if not latest_ver:
        return content, False

    print(f"Current: {current_ver}, Latest: {latest_ver}")
    if int(latest_ver) <= int(current_ver):
        print("Already up to date.")
        return content, False

    print(f"Updating llama-swap to {latest_ver}...")
    new_content = url_pattern.sub(rf"\g<1>{latest_ver}\g<3>{latest_ver}\g<5>", content)

    # Replace first hash after the URL with dummy
    new_m = url_pattern.search(new_content)
    start_pos = new_m.end()

    hash_pattern = re.compile(r'(hash\s*=\s*")(sha256-.*?|)";')
    hm = hash_pattern.search(new_content, pos=start_pos)
    if not hm:
        print("Could not find hash field for llama-swap.")
        return content, False

    new_content = new_content[:hm.start(2)] + DUMMY_HASH + new_content[hm.end(2):]
    return new_content, True


def update_ollama_like(content: str, attr_name: str) -> tuple[str, bool]:
    """
    Update <attr_name> version to latest ollama semver.
    Then set hash (and vendorHash if present) to dummy.
    """
    print(f"\n--- Checking {attr_name} ---")
    version_pattern = re.compile(
        rf'({re.escape(attr_name)}\s*=\s*.*?version\s*=\s*")([^"]+)(";)',
        re.DOTALL,
    )
    m = version_pattern.search(content)
    if not m:
        print(f"Could not find {attr_name} version definition.")
        return content, False

    current_ver = m.group(2)
    latest_ver = get_latest_ollama_tag()
    if not latest_ver:
        return content, False

    print(f"Current: {current_ver}, Latest: {latest_ver}")

    cur_t = _semver_tuple(current_ver)
    lat_t = _semver_tuple(latest_ver)
    if cur_t is None or lat_t is None:
        print("Could not compare versions (non-semver). Skipping.")
        return content, False

    if lat_t <= cur_t:
        print("Already up to date.")
        return content, False

    print(f"Updating {attr_name} to {latest_ver}...")
    new_content = version_pattern.sub(rf"\g<1>{latest_ver}\g<3>", content)

    ver_end = m.end()

    hash_pattern = re.compile(r'(hash\s*=\s*")(sha256-.*?|)";')
    hm = hash_pattern.search(new_content, pos=ver_end)
    if not hm:
        print(f"Could not find hash field for {attr_name}.")
        return content, False
    new_content = new_content[:hm.start(2)] + DUMMY_HASH + new_content[hm.end(2):]

    vendor_pattern = re.compile(r'(vendorHash\s*=\s*")(sha256-.*?|)";')
    vm = vendor_pattern.search(new_content, pos=ver_end)
    if vm:
        new_content = new_content[:vm.start(2)] + DUMMY_HASH + new_content[vm.end(2):]
    else:
        print(f"Note: {attr_name} has no vendorHash; only updated hash.")

    return new_content, True


# -------------------------
# Hash capture via nix build
# -------------------------

def get_new_hash(pkg_attribute: str, config_name: str) -> str | None:
    pkg_seg = nix_attr_segment(pkg_attribute)
    cfg_seg = nix_attr_segment(config_name)

    print(f"Attempting to build {pkg_attribute} (config {config_name}) to capture new hash...")
    cmd = [
        "nix",
        "build",
        "--extra-experimental-features",
        "nix-command flakes",
        f".#nixosConfigurations.{cfg_seg}.pkgs.{pkg_seg}",
        "--no-link",
        "--cores",
        "1",
    ]

    res = subprocess.run(cmd, capture_output=True, text=True)
    out = (res.stdout or "") + "\n" + (res.stderr or "")

    m = re.search(r"(?m)^\s*got:\s*(sha256-[A-Za-z0-9+/=._-]+)\s*$", out)
    if not m:
        print(f"Build failed but could not extract new hash for {pkg_attribute}.")
        print("----- nix build output (stdout+stderr) -----")
        print(out.strip())
        print("------------------------------------------")
        return None

    return m.group(1)


# -------------------------
# Main
# -------------------------

def main() -> int:
    script_path = Path(__file__)
    file_path = locate_package_overrides(script_path)

    config_name = infer_config_name_from_overrides_path(file_path)
    if not config_name:
        raise RuntimeError(f"Could not infer nixosConfigurations name from path: {file_path}")

    print(f"Using:  {file_path}")
    print(f"Config: {config_name}")

    content = file_path.read_text(encoding="utf-8")

    # llama-cpp
    content, updated = update_llama_cpp(content)
    if updated:
        file_path.write_text(content, encoding="utf-8")
        h = get_new_hash("llama-cpp", config_name)
        if not h:
            return 1
        content = replace_one_dummy(content, h)
        file_path.write_text(content, encoding="utf-8")
        print("Successfully updated llama-cpp.")

    # llama-swap
    content, updated = update_llama_swap(content)
    if updated:
        file_path.write_text(content, encoding="utf-8")
        h = get_new_hash("llama-swap", config_name)
        if not h:
            return 1
        content = replace_one_dummy(content, h)
        file_path.write_text(content, encoding="utf-8")
        print("Successfully updated llama-swap.")

    # ollama
    content, updated = update_ollama_like(content, "ollama")
    if updated:
        file_path.write_text(content, encoding="utf-8")

        h1 = get_new_hash("ollama", config_name)
        if not h1:
            return 1
        content = replace_one_dummy(content, h1)
        file_path.write_text(content, encoding="utf-8")
        print(f"Successfully updated ollama hash: {h1}")

        if DUMMY_HASH in content:
            h2 = get_new_hash("ollama", config_name)
            if not h2:
                return 1
            content = replace_one_dummy(content, h2)
            file_path.write_text(content, encoding="utf-8")
            print(f"Successfully updated ollama vendorHash: {h2}")

    # ollama-rocm
    content, updated = update_ollama_like(content, "ollama-rocm")
    if updated:
        file_path.write_text(content, encoding="utf-8")

        h1 = get_new_hash("ollama-rocm", config_name)
        if not h1:
            return 1
        content = replace_one_dummy(content, h1)
        file_path.write_text(content, encoding="utf-8")
        print(f"Successfully updated ollama-rocm hash: {h1}")

        if DUMMY_HASH in content:
            h2 = get_new_hash("ollama-rocm", config_name)
            if not h2:
                return 1
            content = replace_one_dummy(content, h2)
            file_path.write_text(content, encoding="utf-8")
            print(f"Successfully updated ollama-rocm vendorHash: {h2}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
