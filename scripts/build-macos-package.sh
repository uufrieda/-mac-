#!/usr/bin/env bash
set -euo pipefail

VERSION="${VERSION:-1.1.0}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${REPO_ROOT}/build/macos"
APP_ROOT="${BUILD_DIR}/app-root"
APP_PATH="${APP_ROOT}/她先.app"
SQUIRREL_PKG="${REPO_ROOT}/vendor/Squirrel-1.1.2.pkg"
SQUIRREL_URL="${SQUIRREL_URL:-https://github.com/rime/squirrel/releases/download/1.1.2/Squirrel-1.1.2.pkg}"
CORE_PKG="${BUILD_DIR}/shefirst-core.pkg"
DIST_DIR="${REPO_ROOT}/dist"
PRODUCT_PKG="${DIST_DIR}/她先-${VERSION}.pkg"
HASH_FILE="${DIST_DIR}/她先-${VERSION}.sha256.txt"

if [[ ! -f "${SQUIRREL_PKG}" ]]; then
  mkdir -p "$(dirname "${SQUIRREL_PKG}")"
  echo "Downloading Squirrel 1.1.2..."
  curl --fail --location --retry 3 --output "${SQUIRREL_PKG}" "${SQUIRREL_URL}"
fi

rm -rf "${BUILD_DIR}"
mkdir -p "${APP_ROOT}" "${DIST_DIR}"

pkgutil --expand-full "${SQUIRREL_PKG}" "${BUILD_DIR}/squirrel-expanded"
cp -R "${BUILD_DIR}/squirrel-expanded/Payload/Squirrel.app" "${APP_PATH}"

cp "${REPO_ROOT}/macos/Info/Info.plist" "${APP_PATH}/Contents/Info.plist"

cp "${REPO_ROOT}/rime/shefirst.schema.yaml" "${APP_PATH}/Contents/SharedSupport/shefirst.schema.yaml"
cp "${REPO_ROOT}/rime/shefirst_phrases.txt" "${APP_PATH}/Contents/SharedSupport/shefirst_phrases.txt"
cp "${REPO_ROOT}/rime/rime.lua" "${APP_PATH}/Contents/SharedSupport/rime.lua"
cp "${REPO_ROOT}/rime/default.yaml" "${APP_PATH}/Contents/SharedSupport/default.yaml"
cp "${REPO_ROOT}/rime/squirrel.yaml" "${APP_PATH}/Contents/SharedSupport/squirrel.yaml"

cp -R "${REPO_ROOT}/macos/Resources/." "${APP_PATH}/Contents/Resources/"

ICON_PNG="${BUILD_DIR}/SheFirst-1024.png"
MENU_PDF="${BUILD_DIR}/rime.pdf"
ICONSET="${BUILD_DIR}/SheFirst.iconset"
swift "${REPO_ROOT}/tools/make_icon.swift" "${ICON_PNG}" "${MENU_PDF}"
mkdir -p "${ICONSET}"
sips -z 16 16 "${ICON_PNG}" --out "${ICONSET}/icon_16x16.png" >/dev/null
sips -z 32 32 "${ICON_PNG}" --out "${ICONSET}/icon_16x16@2x.png" >/dev/null
sips -z 32 32 "${ICON_PNG}" --out "${ICONSET}/icon_32x32.png" >/dev/null
sips -z 64 64 "${ICON_PNG}" --out "${ICONSET}/icon_32x32@2x.png" >/dev/null
sips -z 128 128 "${ICON_PNG}" --out "${ICONSET}/icon_128x128.png" >/dev/null
sips -z 256 256 "${ICON_PNG}" --out "${ICONSET}/icon_128x128@2x.png" >/dev/null
sips -z 256 256 "${ICON_PNG}" --out "${ICONSET}/icon_256x256.png" >/dev/null
sips -z 512 512 "${ICON_PNG}" --out "${ICONSET}/icon_256x256@2x.png" >/dev/null
sips -z 512 512 "${ICON_PNG}" --out "${ICONSET}/icon_512x512.png" >/dev/null
cp "${ICON_PNG}" "${ICONSET}/icon_512x512@2x.png"
iconutil -c icns "${ICONSET}" -o "${APP_PATH}/Contents/Resources/Rime.icns"
cp "${MENU_PDF}" "${APP_PATH}/Contents/Resources/rime.pdf"
cp "${REPO_ROOT}/LICENSE" "${APP_PATH}/Contents/Resources/LICENSE.txt"
cp "${REPO_ROOT}/THIRD_PARTY_NOTICES.md" "${APP_PATH}/Contents/Resources/THIRD_PARTY_NOTICES.md"

mkdir -p "${APP_PATH}/Contents/SharedSupport/build" "${BUILD_DIR}/rime-user"
"${APP_PATH}/Contents/MacOS/rime_deployer" --build \
  "${BUILD_DIR}/rime-user" \
  "${APP_PATH}/Contents/SharedSupport" \
  "${APP_PATH}/Contents/SharedSupport/build"

codesign --force --deep --sign - "${APP_PATH}"

pkgbuild \
  --root "${APP_ROOT}" \
  --install-location "/Library/Input Methods" \
  --identifier "com.shexian.inputmethod.SheX" \
  --version "${VERSION}" \
  --component-plist "${REPO_ROOT}/package/component.plist" \
  --scripts "${REPO_ROOT}/package/scripts" \
  "${CORE_PKG}"

sed "/<pkg-ref id=\"com.shexian.inputmethod.SheX\" version=/s/version=\"[^\"]*\"/version=\"${VERSION}\"/" \
  "${REPO_ROOT}/package/Distribution.xml" > "${BUILD_DIR}/Distribution.xml"

productbuild \
  --distribution "${BUILD_DIR}/Distribution.xml" \
  --resources "${REPO_ROOT}/package/resources" \
  --package-path "${BUILD_DIR}" \
  "${PRODUCT_PKG}"

shasum -a 256 "${PRODUCT_PKG}" | awk '{print $1}' > "${HASH_FILE}"

echo "Built ${PRODUCT_PKG}"
echo "SHA-256 $(cat "${HASH_FILE}")"
