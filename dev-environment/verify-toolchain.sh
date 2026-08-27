#!/usr/bin/env bash
set -euo pipefail

for cmd in node npm git pdflatex latex tex4ht t4ht dvisvgm; do
  command -v "$cmd" >/dev/null || {
    echo "Missing required command: $cmd" >&2
    exit 1
  }
done

printf '%-14s %s\n' 'node' "$(node --version)"
printf '%-14s %s\n' 'npm' "$(npm --version)"
printf '%-14s %s\n' 'git' "$(git --version)"
printf '%-14s %s\n' 'pdflatex' "$(pdflatex --version | head -n 1)"
printf '%-14s %s\n' 'latex' "$(latex --version | head -n 1)"
printf '%-14s %s\n' 'tex4ht' "$(command -v tex4ht)"
printf '%-14s %s\n' 't4ht' "$(command -v t4ht)"
printf '%-14s %s\n' 'dvisvgm' "$(dvisvgm --version | head -n 1)"

echo
echo "Toolchain verification passed."
