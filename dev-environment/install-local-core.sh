#!/usr/bin/env bash
set -euo pipefail

COMPONENTS_DIR="${COMPONENTS_DIR:-/workspace/components}"
TESTFILES_DIR="${TESTFILES_DIR:-/workspace/testFiles}"
CORE_DIR="${COMPONENTS_DIR}/core"

if [[ ! -f "${CORE_DIR}/package.json" ]]; then
  echo "Missing local core package: ${CORE_DIR}" >&2
  exit 1
fi

if [[ ! -f "${TESTFILES_DIR}/package.json" ]]; then
  echo "Missing testFiles package.json: ${TESTFILES_DIR}" >&2
  exit 1
fi

TMPDIR="$(mktemp -d)"
trap 'rm -rf "${TMPDIR}"' EXIT

cd "${CORE_DIR}"

# Pack instead of installing the directory directly. A directory install becomes
# a symlink, causing Node/esbuild to resolve core dependencies relative to the
# components checkout rather than testFiles/node_modules. A tarball installation
# behaves like the published npm package and exercises the development source
# with normal package-resolution semantics.
npm pack --ignore-scripts --pack-destination "${TMPDIR}" >/tmp/ximera-core-pack-name.txt
TARBALL="${TMPDIR}/$(tail -n 1 /tmp/ximera-core-pack-name.txt)"
rm -f /tmp/ximera-core-pack-name.txt

cd "${TESTFILES_DIR}"
npm install --no-save --package-lock=false --ignore-scripts "${TARBALL}"

echo
echo "Installed local @ximera/core from packed development source:"
npm ls @ximera/core @modulus-learning/agent --depth=1 || true

echo
echo "Production entry now contains:"
grep -n -E 'ModulusAgent|createModulusAgent' node_modules/@ximera/core/index.js
