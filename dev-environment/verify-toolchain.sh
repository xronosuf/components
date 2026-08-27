#!/usr/bin/env bash
set -euo pipefail

printf '%-14s %s\n' 'node' "$(node --version)"
printf '%-14s %s\n' 'npm' "$(npm --version)"
printf '%-14s %s\n' 'git' "$(git --version)"
printf '%-14s %s\n' 'pdflatex' "$(pdflatex --version | head -n 1)"
printf '%-14s %s\n' 'latex' "$(latex --version | head -n 1)"
printf '%-14s %s\n' 'tex4ht' "$(tex4ht 2>&1 | head -n 1 || true)"
printf '%-14s %s\n' 't4ht' "$(t4ht 2>&1 | head -n 1 || true)"
printf '%-14s %s\n' 'dvisvgm' "$(dvisvgm --version | head -n 1)"

for cmd in node npm git pdflatex latex tex4ht t4ht dvisvgm; do
  command -v "$cmd" >/dev/null || {
    echo "Missing required command: $cmd" >&2
    exit 1
  }
done

echo
 echo "Toolchain verification passed."
