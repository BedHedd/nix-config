#!/usr/bin/env python3
from pathlib import Path
import os, sys, subprocess, json, re, textwrap

ROOT = Path(os.environ.get("REPO_ROOT", Path.cwd())).resolve()

if not (ROOT / "flake.nix").exists():
    sys.exit(
      "❌  Please run `nix run .#host-wizard` **from the root of your nix-config repo**."
    )
def run(cmd): return subprocess.check_output(cmd, text=True).strip()

def is_linux():  return sys.platform.startswith("linux")
def is_darwin(): return sys.platform == "darwin"

def detect_gpu():
    if not is_linux():
        return None
    out = run(["lspci", "-nn"])
    if   "NVIDIA" in out: return "nvidia"
    elif "AMD"     in out: return "amd"
    else:                 return "intel"

def nix_eval(expr):
    """Evaluate a Nix expression and return JSON value."""
    return json.loads(run(["nix", "eval", "--impure", "--expr",
                           f"builtins.toJSON ({expr})"]))

def default_tz():
    return nix_eval("""
      let pkgs = import <nixpkgs> {};
          lib  = pkgs.lib;
      in  (import ./modules/universal.nix { inherit pkgs lib; }).time.timeZone
    """)

def scrape_existing(path: Path):
    txt = path.read_text()
    out = {}
    if m := re.search(r'time\.timeZone\s*=\s*"([^"]+)"', txt):
        out["timezone"] = m.group(1)
    if m := re.search(r'networking\.hostName\s*=\s*"([^"]+)"', txt):
        out["hostname"] = m.group(1)
    if m := re.search(r'i18n\.defaultLocale\s*=\s*"([^"]+)"', txt):
        out["locale"] = m.group(1)    
    if   "common-gpu-amd"    in txt: out["gpu"] = "amd"
    elif "common-gpu-nvidia" in txt: out["gpu"] = "nvidia"
    elif "common-gpu-intel"  in txt: out["gpu"] = "intel"
    return out, txt

def ask(prompt, default=None):
    inp = input(f"{prompt} [{default}]: ").strip()
    return inp or default

def ask_yes_no(prompt, default="y"):
    ans = input(f"{prompt} (y/n) [{default}]: ").lower()
    return (ans or default).startswith("y")

def main():
    print("🔧  Nix Host-Wizard\n")

    # ── Step 1  OS & GPU ────────────────────────────────────────────
    os_role = "darwin-laptop" if is_darwin() else "linux-desktop"
    gpu = detect_gpu()

    # ── Step 2  look for existing config ───────────────────────────
    existing_txt = None
    existing_vals = {}
    if is_linux() and Path("/etc/nixos/configuration.nix").exists():
        if ask_yes_no("Found /etc/nixos/configuration.nix → import settings?"):
            existing_vals, existing_txt = scrape_existing(
                Path("/etc/nixos/configuration.nix"))
    elif ask_yes_no("No config found.  Do you want to supply a path?","n"):
        p = Path(ask("Path to configuration.nix")).expanduser()
        if p.exists():
            existing_vals, existing_txt = scrape_existing(p)

    # ── Step 3  interactive questions ──────────────────────────────
    hostname = ask("Hostname", existing_vals.get("hostname") or "my-machine")
    user     = ask("Primary user", "progressedd")
    role     = ask("Role (linux-desktop/linux-laptop/mac-laptop/headless)",
                   os_role)
    tz       = ask("Timezone", existing_vals.get("timezone") or default_tz())

    # ── Step 4  scaffold host folder ───────────────────────────────
    host_dir = ROOT / "hosts" / hostname
    host_dir.mkdir(parents=True, exist_ok=True)

    (host_dir / "default.nix").write_text(textwrap.dedent(f"""
      {{ modules, pkgs, host, ... }}:
      {{
        imports = [
          modules.universal
          modules.{ 'linux' if role.startswith('linux') else 'darwin' }
        ] ++ (pkgs.lib.optionals pkgs.stdenv.isLinux
               [ modules.kde ])  # change if you only want on desktops
          ++ [ ./hardware-configuration.nix 
               ../../users/{user}.nix ];

        networking.hostName = host;
        time.timeZone = "{tz}";
      }}
    """).lstrip())

    if existing_txt:
        (host_dir / "original-configuration.nix").write_text(existing_txt)

    if is_linux():
        hw = run(["nixos-generate-config", "--show-hardware-config"])
        (host_dir / "hardware-configuration.nix").write_text(hw)
    else:
        (host_dir / "hardware-configuration.nix").write_text(
            "# macOS hardware config not required\n")

    print("\n✅  Created hosts/{hostname}")
    print(f"   Next step:\n   sudo nixos-rebuild switch --flake .#{hostname}\n")

if __name__ == "__main__":
    main()
