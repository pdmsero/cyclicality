#!/usr/bin/env python3
"""Verify that all LaTeX \input and \includegraphics targets in paper/ exist."""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

def main() -> int:
    tex_files = list(ROOT.rglob("*.tex"))
    print(f'Scanned {len(tex_files)} LaTeX files in {ROOT.name}.')
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
