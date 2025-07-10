#!/usr/bin/env python3
# scripts/setup-wizard.py
import os, sys, subprocess, json, re, textwrap
from pathlib import Path
from typing import Dict, Tuple

# ─────────── repo root (must contain flake.nix) ──────────────────────────
ROOT = Path(os.environ.get("REPO_ROOT", Path.cwd())).resolve()
if not (ROOT / "flake.nix").exists():
    sys.exit("❌  Run the wizard from the root of your nix-config repo.")

MODULES_FILE = ROOT / "modules" / "default.nix"   ### FIX — single-level modules

# ─────────── tiny helpers ────────────────────────────────────────────────
def run(cmd): return subprocess.check_output(cmd, text=True).strip()
def is_linux():  return sys.platform.startswith("linux")
def is_darwin(): return sys.platform == "darwin"

def detect_gpu() -> str | None:
    if not is_linux():
        return None
    out = run(["lspci", "-nn"])
    if   "NVIDIA" in out: return "nvidia"
    elif "AMD"   in out: return "amd"
    else:                 return "intel"

def nix_json(expr: str):
    return json.loads(run(["nix", "eval", "--impure", "--expr",
                           f"builtins.toJSON ({expr})"]))

### FIX — read defaults from modules/default.nix.universal
def _universal_expr(attr: str) -> str:
    # Nix needs an absolute path as a string literal
    path = json.dumps(str(MODULES_FILE))
    return (f'let pkgs=import <nixpkgs> {{}}; lib=pkgs.lib; '
            f'mods=import {path} {{ inherit pkgs lib; }}; '
            f'in mods.universal.{attr}')

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
    if   "common-gpu-amd"    in txt: out["gpu"] = "amd"
    elif "common-gpu-nvidia" in txt: out["gpu"] = "nvidia"
    elif "common-gpu-intel"  in txt: out["gpu"] = "intel"
    return out, txt

# ─────────── minimal TUI helpers ─────────────────────────────────────────
def ask(q, default=None): return input(f"{q} [{default}]: ").strip() or default
def ask_yn(q, default="y"):
    a = input(f"{q} (y/n) [{default}]: ").lower().strip()
    return (a or default).startswith("y")

# ─────────── main wizard flow ────────────────────────────────────────────
def main():
    print("🔧  Nix Host-Wizard\n")

    role_default = "darwin-laptop" if is_darwin() else "linux-desktop"
    gpu = detect_gpu()

    # Import existing cfg?
    existing, existing_txt = {}, None
    cfg_path = Path("/etc/nixos/configuration.nix")
    if is_linux() and cfg_path.exists() and ask_yn("Found /etc/nixos/configuration.nix → import settings?"):
        existing, existing_txt = scrape_existing(cfg_path)
    elif ask_yn("No config found. Supply a path?", "n"):
        p = Path(ask("Path to configuration.nix")).expanduser()
        if p.exists(): existing, existing_txt = scrape_existing(p)

    # Interactive prompts
    hostname = ask("Hostname", existing.get("hostname") or "my-machine")
    user     = ask("Primary user", "progressedd")
    role     = ask("Role (linux-desktop/linux-laptop/mac-laptop/headless)", role_default)
    tz       = ask("Timezone", existing.get("timezone") or default_tz())
    loc      = ask("Locale",   existing.get("locale")   or default_locale())

    extra_locale = None
    if "extra_locale" in existing and ask_yn("Copy extraLocaleSettings?", "y"):
        extra_locale = existing["extra_locale"]

    # Create host folder
    host_dir = ROOT / "hosts" / hostname
    host_dir.mkdir(parents=True, exist_ok=True)

    # Build override snippets
    override_locale = (
        f'  i18n.defaultLocale = "{loc}";\n'
        if loc != default_locale() else ""
    )
    override_extra = (
        textwrap.dedent(f"""
          i18n.extraLocaleSettings = {{
{_dict_to_nix_block(extra_locale)}
          }};
        """) if extra_locale else "")

    # Write default.nix
    (host_dir / "default.nix").write_text(textwrap.dedent(f"""
      {{ modules, pkgs, host, ... }}:
      {{
        imports = [
          modules.universal
          modules.{"linux" if role.startswith("linux") else "darwin"}
        ] ++ (pkgs.lib.optionals pkgs.stdenv.isLinux [ modules.kde ])
          ++ [ ./hardware-configuration.nix ../../users/{user}.nix ];

        networking.hostName = host;
        time.timeZone       = "{tz}";
{override_locale}{override_extra}
      }}
    """).lstrip())

    # Save original config & hardware-configuration.nix
    if existing_txt:
        (host_dir / "original-configuration.nix").write_text(existing_txt)

    if is_linux():
        hw = run(["nixos-generate-config", "--show-hardware-config"])
        (host_dir / "hardware-configuration.nix").write_text(hw)
    else:
        (host_dir / "hardware-configuration.nix").write_text("# nix-darwin: no hw file\n")

    # Final message
    rebuild = "darwin-rebuild" if is_darwin() else "sudo nixos-rebuild"
    print(f"\n✅  Created hosts/{hostname}")
    print(f"   Next: {rebuild} switch --flake .#{hostname}\n")

if __name__ == "__main__":
    main()
