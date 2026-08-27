#!/usr/bin/env bash
set -euo pipefail

for cmd in node npm git pdflatex latex kpsewhich tex4ht t4ht dvisvgm tlmgr; do
  command -v "$cmd" >/dev/null || {
    echo "Missing required command: $cmd" >&2
    exit 1
  }
done

TEXLIVE_VERSION="$(kpsewhich --version | head -n 1)"
TEXLIVE_ROOT="$(kpsewhich -var-value=TEXMFROOT)"

if [[ "$TEXLIVE_VERSION" != *"2026"* ]]; then
  echo "ERROR: TeX Live 2026 is required for the Ximera development environment." >&2
  echo "Active TeX reports: $TEXLIVE_VERSION" >&2
  exit 1
fi

printf '%-14s %s\n' 'node' "$(node --version)"
printf '%-14s %s\n' 'npm' "$(npm --version)"
printf '%-14s %s\n' 'git' "$(git --version)"
printf '%-14s %s\n' 'texlive' "$TEXLIVE_VERSION"
printf '%-14s %s\n' 'texmfroot' "$TEXLIVE_ROOT"
printf '%-14s %s\n' 'tlmgr' "$(tlmgr --version | head -n 1)"
printf '%-14s %s\n' 'pdflatex' "$(pdflatex --version | head -n 1)"
printf '%-14s %s\n' 'latex' "$(latex --version | head -n 1)"
printf '%-14s %s\n' 'tex4ht' "$(command -v tex4ht)"
printf '%-14s %s\n' 't4ht' "$(command -v t4ht)"
printf '%-14s %s\n' 'dvisvgm' "$(dvisvgm --version | head -n 1)"

echo
echo "Toolchain verification passed (TeX Live 2026 active)."
