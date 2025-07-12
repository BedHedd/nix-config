#!/usr/bin/env python3
# scripts/setup-wizard.py
import os, sys, subprocess, json, re, textwrap
from pathlib import Path

ROOT = Path(os.environ.get("REPO_ROOT", Path.cwd())).resolve()
if not (ROOT / "flake.nix").exists():
    sys.exit("❌  Run the wizard from the root of your nix-config repo.")

SCRIPTS_DIR = ROOT / "scripts"          # ← repo’s scripts directory
sys.path.insert(0, str(SCRIPTS_DIR))    # helper.py, template.py

from helper import *
from template import *
# ─────────── main wizard flow ────────────────────────────────────────────
def main() -> None:
    print("🔧  Nix setup-wizard\n")

    role_default = "darwin-laptop" if is_darwin() else "linux-desktop"
    gpu          = detect_gpu()
    gpu_import = ""

    # ── import existing cfg? ────────────────────────────────────────────
    existing, existing_txt = {}, None
    cfg_path = Path("/etc/nixos/configuration.nix")
    if is_linux() and cfg_path.exists() and ask_yn("Found /etc/nixos/configuration.nix → import settings?"):
        existing, existing_txt = scrape_existing(cfg_path)
    elif ask_yn("No config found. Supply a path?", "n"):
        p = Path(ask("Path to configuration.nix")).expanduser()
        if p.exists():
            existing, existing_txt = scrape_existing(p)
    
    state_version = existing.get("state_version") or "<your-default-stateVersion>"
        
    # ── interactive prompts ────────────────────────────────────────────
    hostname = ask("Hostname", existing.get("hostname") or "my-machine")
    user     = ask("Primary user", "progressedd")
    if gpu:
        prompt = f"Detected GPU: {gpu}. Add a import from nixos-hardware (https://github.com/NixOS/nixos-hardware/tree/master/common/gpu) for the gpu?"
        if ask_yn(prompt, "y"):
            gpu_import = f"nixos-hardware.nixosModules.common-gpu-{gpu}\n"
    role     = menu_select(
        prompt="Select role:",
        choices=["linux-desktop", "linux-laptop", "mac-laptop", "headless"],
        default=role_default,
    )
    is_laptop = (role == "linux-laptop") 
    is_laptop_str = str(is_laptop).lower() 
    os_module = "linux" if role.startswith("linux") else "darwin"
    tz  = ask("Timezone", existing.get("timezone") or default_tz())
    loc = ask("Locale",   existing.get("locale")   or default_locale())

    extra_locale = None
    if "extra_locale" in existing and ask_yn("Copy extraLocaleSettings?", "y"):
        extra_locale = existing["extra_locale"]

    # ── create host folder ──────────────────────────────────────────────
    host_dir = ROOT / "hosts" / hostname
    host_dir.mkdir(parents=True, exist_ok=True)

    # ── build override snippets ─────────────────────────────────────────
    override_locale = (
        f'  i18n.defaultLocale  = "{loc}";\n'
        if loc != default_locale() else ""
    )
    override_extra = build_extra_locale(extra_locale)

    # ── write hosts/<hostname>/default.nix ──────────────────────────────
    rendered = tmpl.format(os_module = os_module,
                role=role, 
                user=user, 
                gpu_import=gpu_import,
                is_laptop=is_laptop_str, 
                tz=tz, 
                override_locale=override_locale,
                override_extra=override_extra,
                state_version    = state_version,
                )
    (host_dir / "default.nix").write_text(rendered)

    # ── save original cfg & hw-config ──────────────────────────────────
    if is_linux():
        src_hw = Path("/etc/nixos/hardware-configuration.nix")
        if src_hw.exists():
            (host_dir / "hardware-configuration.nix").write_text(src_hw.read_text())
            print("✓  Copied current /etc/nixos/hardware-configuration.nix")
        else:
            # very unlikely, but leave a stub so the import doesn't break
            (host_dir / "hardware-configuration.nix").write_text(
                "# TODO: add hardware-configuration.nix for this host\n"
            )
    else:
        (host_dir / "hardware-configuration.nix").write_text("# nix-darwin: no hw file\n")

    ensure_user_file(ROOT, user) 
    
    # ── final message ──────────────────────────────────────────────────
    rebuild = "darwin-rebuild" if is_darwin() else "sudo nixos-rebuild"
    print(f"\n✅  Created hosts/{hostname}")
    print(f"   Next: {rebuild} switch --flake .#{hostname}\n")


if __name__ == "__main__":
    main()