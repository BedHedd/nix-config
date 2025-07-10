#!/usr/bin/env python3
# scripts/setup-wizard.py
import os, sys, subprocess, json, re, textwrap
from pathlib import Path
from typing import Dict, Tuple

REPO_PATH = Path(os.environ.get("REPO_ROOT", Path.cwd())).resolve()
sys.path.insert(0, str(REPO_PATH)) 

from helper import *
from template import *
# ─────────── main wizard flow ────────────────────────────────────────────
def main() -> None:
    print("🔧  Nix Host-Wizard\n")

    role_default = "darwin-laptop" if is_darwin() else "linux-desktop"
    gpu          = detect_gpu()

    # ── import existing cfg? ────────────────────────────────────────────
    existing, existing_txt = {}, None
    cfg_path = Path("/etc/nixos/configuration.nix")
    if is_linux() and cfg_path.exists() and ask_yn("Found /etc/nixos/configuration.nix → import settings?"):
        existing, existing_txt = scrape_existing(cfg_path)
    elif ask_yn("No config found. Supply a path?", "n"):
        p = Path(ask("Path to configuration.nix")).expanduser()
        if p.exists():
            existing, existing_txt = scrape_existing(p)

    # ── interactive prompts ────────────────────────────────────────────
    hostname = ask("Hostname", existing.get("hostname") or "my-machine")
    user     = ask("Primary user", "progressedd")
    role     = menu_select(
        prompt="Select role:",
        choices=["linux-desktop", "linux-laptop", "mac-laptop", "headless"],
        default=role_default,
    )
    is_laptop = (role == "linux-laptop") 
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
    

    (host_dir / "default.nix").write_text(tmpl)

    # ── save original cfg & hw-config ──────────────────────────────────
    if existing_txt:
        (host_dir / "original-configuration.nix").write_text(existing_txt)

    if is_linux():
        hw = run(["nixos-generate-config", "--show-hardware-config"])
        (host_dir / "hardware-configuration.nix").write_text(hw)
    else:
        (host_dir / "hardware-configuration.nix").write_text("# nix-darwin: no hw file\n")

    # ── final message ──────────────────────────────────────────────────
    rebuild = "darwin-rebuild" if is_darwin() else "sudo nixos-rebuild"
    print(f"\n✅  Created hosts/{hostname}")
    print(f"   Next: {rebuild} switch --flake .#{hostname}\n")


if __name__ == "__main__":
    main()