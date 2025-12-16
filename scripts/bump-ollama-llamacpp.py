#!/usr/bin/env python3
from __future__ import annotations

import re
import shutil
from dataclasses import dataclass
from pathlib import Path


# -------------------------
# Values (from your output)
# -------------------------

LLAMA_CPP_VERSION = "7415"
LLAMA_CPP_HASH    = "sha256-Kd21cwA319z2rmlqQy5SnAZTc6bsuLkB+4sCTpSnYIM="

OLLAMA_VERSION    = "0.13.3"
OLLAMA_HASH       = "sha256-DsAgosnvkyGFPKSjjnE9dZ37CfqAIlvodpVjHLihX2A="
OLLAMA_VENDORHASH = "sha256-rKRRcwmon/3K2bN7iQaMap5yNYKMCZ7P0M1C2hv4IlQ="


# -------------------------
# Locate package-overrides.nix
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
    here = scriptI = script_path.resolve().parent
    # 1) nearest upwards from script dir
    p = find_nearest_file_upwards(here, "package-overrides.nix")
    if p:
        return p
    # 2) search downwards from repo-ish root guess (2 levels up), then from cwd
    for base in [script_path.resolve().parents[1], Path.cwd()]:
        p = find_first_file_downwards(base, "package-overrides.nix")
        if p:
            return p
    raise RuntimeError("Could not find package-overrides.nix (searched upwards from script dir and downwards from likely roots).")


# -------------------------
# Patching utilities
# -------------------------

@dataclass
class BlockSpan:
    start: int
    end: int

def _find_attrset_block(text: str, name: str) -> BlockSpan:
    """
    Finds the block for:  <name> = ... ;
    by scanning from the assignment to the terminating ';' at brace depth 0.
    Works for nested attrsets and overrideAttrs blocks.
    """
    m = re.search(rf"(?m)^\s*{re.escape(name)}\s*=\s*", text)
    if not m:
        raise RuntimeError(f"Could not find assignment for '{name} = ...' in file")

    i = m.start()
    j = m.end()

    depth = 0
    in_str = False
    esc = False

    k = j
    while k < len(text):
        ch = text[k]

        if in_str:
            if esc:
                esc = False
            elif ch == "\\":
                esc = True
            elif ch == '"':
                in_str = False
        else:
            if ch == '"':
                in_str = True
            elif ch in "{[(":
                depth += 1
            elif ch in "}])":
                depth = max(0, depth - 1)
            elif ch == ";" and depth == 0:
                return BlockSpan(start=i, end=k + 1)

        k += 1

    raise RuntimeError(f"Could not determine end of '{name}' block (missing terminating ';'?)")

def _replace_first_quoted_attr(block: str, attr: str, new_value: str) -> tuple[str, bool]:
    """
    Replace: attr = "...";
    (first match only)
    """
    pat = re.compile(rf'(\b{re.escape(attr)}\s*=\s*")([^"]*)(";\s*)')
    m = pat.search(block)
    if not m:
        return block, False
    return block[:m.start()] + m.group(1) + new_value + m.group(3) + block[m.end():], True

def patch_package_overrides(path: Path) -> None:
    original = path.read_text(encoding="utf-8")

    # ---- patch ollama block (scoped) ----
    span = _find_attrset_block(original, "ollama")
    ollama_block = original[span.start:span.end]

    ollama_block, ok_v  = _replace_first_quoted_attr(ollama_block, "version",    OLLAMA_VERSION)
    ollama_block, ok_h  = _replace_first_quoted_attr(ollama_block, "hash",       OLLAMA_HASH)
    ollama_block, ok_vh = _replace_first_quoted_attr(ollama_block, "vendorHash", OLLAMA_VENDORHASH)

    if not (ok_v and ok_h and ok_vh):
        raise RuntimeError(
            "Failed to patch ollama block. "
            f"Found version={ok_v}, hash={ok_h}, vendorHash={ok_vh}. "
            "Expected quoted attrs like: version = \"...\"; hash = \"...\"; vendorHash = \"...\";"
        )

    updated = original[:span.start] + ollama_block + original[span.end:]


    # ---- patch llama-cpp block (scoped) ----
    span = _find_attrset_block(updated, "llama-cpp")
    llama_block = updated[span.start:span.end]

    llama_block, ok_lv = _replace_first_quoted_attr(llama_block, "version", LLAMA_CPP_VERSION)

    # 'hash' might appear multiple times inside llama-cpp block; patch the first one.
    llama_block, ok_lh = _replace_first_quoted_attr(llama_block, "hash",    LLAMA_CPP_HASH)

    if not (ok_lv and ok_lh):
        raise RuntimeError(
            "Failed to patch llama-cpp block. "
            f"Found version={ok_lv}, hash={ok_lh}. "
            "Expected quoted attrs like: version = \"...\"; hash = \"...\";"
        )

    updated = updated[:span.start] + llama_block + updated[span.end:]


    # ---- write with backup ----
    backup = path.with_suffix(path.suffix + ".bak")
    shutil.copy2(path, backup)
    path.write_text(updated, encoding="utf-8")
    print(f"Updated: {path}")
    print(f"Backup:  {backup}")


def main() -> int:
    script_path = Path(__file__)
    target = locate_package_overrides(script_path)
    patch_package_overrides(target)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
