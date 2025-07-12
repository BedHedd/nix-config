import os, sys, subprocess, json, re, textwrap
from pathlib import Path
from typing import Dict, Tuple

ROOT = Path(os.environ.get("REPO_ROOT", Path.cwd())).resolve()
if not (ROOT / "flake.nix").exists():
    sys.exit("❌  Run the wizard from the root of your nix-config repo.")
MODULES_FILE = ROOT / "modules" / "universal.nix"

def run(cmd): return subprocess.check_output(cmd, text=True).strip()
def is_linux():  return sys.platform.startswith("linux")
def is_darwin(): return sys.platform == "darwin"

def detect_gpu() -> str | None:
    """
    Return 'nvidia', 'amd', or 'intel' based on the primary GPU in `lspci`.
    """
    if not is_linux():
        return None

    out = run(["lspci", "-nn"])
    # keep only VGA or 3D controller entries
    gpu_lines = [
        line for line in out.splitlines()
        if re.search(r"\b(VGA compatible controller|3D controller)\b", line)
    ]

    for line in gpu_lines:
        if "NVIDIA" in line:
            return "nvidia"
        if re.search(r"\b(AMD|ATI)\b", line):
            return "amd"
        if "Intel" in line:
            return "intel"

    # fallback: if there are any VGA lines but no known vendor, just return None
    return None
def nix_json(expr: str):
    return json.loads(run(["nix", "eval", "--impure", "--expr",
                           f"builtins.toJSON ({expr})"]))
def _universal_expr(attr: str) -> str:
    """
    Build a Nix expression that evaluates `attr` inside universal.nix,
    e.g.  attr = "i18n.defaultLocale"  or  "time.timeZone".
    """
    path = json.dumps(str(MODULES_FILE))               # absolute path, quoted
    return (
      f'let pkgs = import <nixpkgs> {{}}; '            # bring in pkgs & lib
      f'    lib  = pkgs.lib; '
      f'in (import {path} {{ inherit pkgs lib; }}).'   # apply the module
      f'{attr}'                                        # pick the field
    )

def build_extra_locale(extra: dict[str, str] | None) -> str:
    """Return a nicely-indented i18n.extraLocaleSettings block (or '')."""
    if not extra:
        return ""
    body = "\n".join(f"    {k} = \"{v}\";" for k, v in extra.items())  # 4-sp
    return (
        "  i18n.extraLocaleSettings = {\n"   # 2-sp left margin
        f"{body}\n"
        "  };\n"
    )

def ensure_user_file(root: Path, user: str, template_name: str = "generic-user.nix"):
    """
    Make sure users/<user>.nix exists.
    If missing, copy users/generic-user.nix and patch __USERNAME__.
    """
    users_dir  = root / "users"
    users_dir.mkdir(exist_ok=True)

    target   = users_dir / f"{user}.nix"
    template = users_dir / template_name

    if target.exists():
        print(f"ℹ️   users/{user}.nix already exists – leaving it untouched")
        return

    if not template.exists():
        sys.exit(f"❌  template {template} not found")

    txt = template.read_text().replace("__USERNAME__", user)
    target.write_text(txt)
    print(f"🆕  Created users/{user}.nix from {template_name}")

def default_tz()     -> str: return nix_json(_universal_expr("time.timeZone"))
def default_locale() -> str: return nix_json(_universal_expr("i18n.defaultLocale"))

def _parse_extra_locale(block: str) -> Dict[str, str]:
    return {k: v for k, v in re.findall(r'([A-Z_]+)\s*=\s*"([^"]+)"', block)}

def _dict_to_nix_block(d: Dict[str, str]) -> str:
    return "\n".join(f'    {k} = "{v}";' for k, v in d.items())

# ─────────── scrape existing configuration.nix ───────────────────────────
def scrape_existing(path: Path) -> Tuple[Dict[str, object], str]:
    txt = path.read_text()
    out: Dict[str, object] = {}
    if m := re.search(r'time\.timeZone\s*=\s*"([^"]+)"', txt):
        out["timezone"] = m.group(1)
    if m := re.search(r'networking\.hostName\s*=\s*"([^"]+)"', txt):
        out["hostname"] = m.group(1)
    if m := re.search(r'i18n\.defaultLocale\s*=\s*"([^"]+)"', txt):
        out["locale"]   = m.group(1)
    if m := re.search(r'i18n\.extraLocaleSettings\s*=\s*\{([^}]+)\}', txt, re.S):
        out["extra_locale"] = _parse_extra_locale(m.group(1))
    return out, txt

# ─────────── minimal TUI helpers ─────────────────────────────────────────
def ask(q, default=None): return input(f"{q} [{default}]: ").strip() or default

def ask_yn(q, default="y"):
    a = input(f"{q} (y/n) [{default}]: ").lower().strip()
    return (a or default).startswith("y")

def menu_select(
    prompt: str,
    choices: list[str],
    default: str | None = None
) -> str:
    """
    Print a numbered menu and return the chosen item.

    • `prompt`  – heading shown above the list.
    • `choices` – list of strings to choose from.
    • `default` – the default item (must be in choices) or None.

    The user can:
      • press <Enter> → get the default;
      • type the number (1-N) → get that item;
      • type the full string → get that item.
    """
    if not choices:
        raise ValueError("choices list is empty")
    if default is None:
        default = choices[0]
    if default not in choices:
        raise ValueError("default must be one of the choices")

    def show_menu():
        print(prompt)
        for i, item in enumerate(choices, 1):
            mark = " ← default" if item == default else ""
            print(f"  [{i}] {item}{mark}")

    show_menu()
    while True:
        ans = input(f"Choice (1-{len(choices)}) [{choices.index(default)+1}]: ").strip()
        if ans == "":
            return default
        if ans.isdigit():
            n = int(ans)
            if 1 <= n <= len(choices):
                return choices[n-1]
        elif ans in choices:
            return ans
        print("  ⚠️  Invalid selection.")    