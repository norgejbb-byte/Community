#!/usr/bin/env bash
# Cloud Agent install script for the DACS Community repository.
#
# Community is a non-normative documentation/index repo (see README.md): it has
# no build step or package manager of its own. Its contributor workflow
# (CONTRIBUTING.md) requires validating each submission's conformance claims
# against the DACS-Standard conformance vectors and validators, which are
# dependency-free Python stdlib tooling. This script makes that standard
# available next to the checkout so those validators are runnable.
#
# The script is idempotent: it can run repeatedly and against a cached checkout.
set -euo pipefail

if ! command -v python3 >/dev/null 2>&1; then
  echo "error: python3 is required but was not found on PATH" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STANDARD_URL="https://github.com/norgejbb-byte/DACS-Standard.git"

# Prefer a sibling checkout when the workspace already provides one (no writes to
# the parent directory in that case); otherwise clone into the always-writable
# home directory so the script works no matter where the repo is checked out.
SIBLING_DIR="$(cd "${REPO_ROOT}/.." && pwd)/DACS-Standard"
if [ -d "${SIBLING_DIR}/.git" ]; then
  STANDARD_DIR="${SIBLING_DIR}"
else
  STANDARD_DIR="${HOME}/DACS-Standard"
fi

if [ -d "${STANDARD_DIR}/.git" ]; then
  echo "DACS-Standard already present at ${STANDARD_DIR}; fetching latest (working tree untouched)"
  git -C "${STANDARD_DIR}" fetch --quiet origin || \
    echo "warning: could not fetch DACS-Standard; using the existing checkout"
else
  echo "Cloning DACS-Standard into ${STANDARD_DIR}"
  git clone --quiet "${STANDARD_URL}" "${STANDARD_DIR}"
fi

echo "Toolchain: $(python3 --version)"
echo "DACS-Standard checkout: ${STANDARD_DIR}"
echo "install complete"
