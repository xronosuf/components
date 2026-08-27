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

# RHEL Podman/runc does not reliably resolve the relative docker-entrypoint.sh
# inherited from the official Node image, so use an absolute shell entrypoint.
# The UF test host also cannot execute image binaries as the image's non-root
# `node` UID. Run as container UID 0 instead. Because Podman itself is rootless,
# container UID 0 maps to the invoking unprivileged host account, not host root.
exec podman run --rm -it \
  --name "${CONTAINER_NAME}" \
  --user 0 \
  --security-opt=no-new-privileges \
  --cap-drop=ALL \
  --entrypoint /bin/bash \
  --volume "${COMPONENTS_DIR}:/workspace/components:Z" \
  --volume "${TESTFILES_DIR}:/workspace/testFiles:Z" \
  --workdir /workspace/testFiles \
  "${IMAGE_NAME}"
