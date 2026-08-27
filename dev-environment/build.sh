#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-ximera-components-dev:latest}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

podman build \
  --file "${REPO_ROOT}/dev-environment/Containerfile" \
  --tag "${IMAGE_NAME}" \
  "${REPO_ROOT}"

echo "Built ${IMAGE_NAME}"
