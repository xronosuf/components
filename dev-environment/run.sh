#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-ximera-components-dev:latest}"
CONTAINER_NAME="${CONTAINER_NAME:-ximera-components-dev}"
COMPONENTS_DIR="${COMPONENTS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
TESTFILES_DIR="${TESTFILES_DIR:-${HOME}/xronos-new-architecture/testFiles}"

if [[ ! -d "${COMPONENTS_DIR}/.git" ]]; then
  echo "COMPONENTS_DIR is not a git checkout: ${COMPONENTS_DIR}" >&2
  exit 1
fi

if [[ ! -d "${TESTFILES_DIR}/.git" ]]; then
  echo "TESTFILES_DIR is not a git checkout: ${TESTFILES_DIR}" >&2
  echo "Clone xronosuf/testFiles and check out tex4npm-testing first." >&2
  exit 1
fi

exec podman run --rm -it \
  --name "${CONTAINER_NAME}" \
  --userns=keep-id \
  --security-opt=no-new-privileges \
  --cap-drop=ALL \
  --volume "${COMPONENTS_DIR}:/workspace/components:Z" \
  --volume "${TESTFILES_DIR}:/workspace/testFiles:Z" \
  --workdir /workspace/testFiles \
  "${IMAGE_NAME}" \
  bash
