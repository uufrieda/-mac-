#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${REPO_ROOT}/build/macos"
APP_PATH="${APP_PATH:-${BUILD_DIR}/app-root/她先.app}"
VERIFY_BIN="${BUILD_DIR}/verify_candidates"
TEST_USER="${BUILD_DIR}/verify-user"

if [[ ! -d "${APP_PATH}" ]]; then
  echo "Missing built app at ${APP_PATH}" >&2
  echo "Run scripts/build-macos-package.sh first." >&2
  exit 2
fi

mkdir -p "${TEST_USER}"

c++ -std=c++17 \
  -I "${REPO_ROOT}/tools" \
  "${REPO_ROOT}/tools/verify_candidates.cc" \
  -Wl,-rpath,"${APP_PATH}/Contents/Frameworks" \
  -Wl,-rpath,"${APP_PATH}/Contents/Frameworks/rime-plugins" \
  "${APP_PATH}/Contents/Frameworks/librime.1.dylib" \
  "${APP_PATH}/Contents/Frameworks/rime-plugins/librime-lua.dylib" \
  -o "${VERIFY_BIN}"

"${VERIFY_BIN}" \
  "${APP_PATH}/Contents/SharedSupport" \
  "${TEST_USER}" \
  "${APP_PATH}/Contents/SharedSupport/build"
