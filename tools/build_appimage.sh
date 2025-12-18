#!/usr/bin/env bash
set -euo pipefail

APP=xcash-wallet-gui
ARCH=x86_64
ROOT="$(pwd)"
OUTDIR="${ROOT}/dist"
APPDIR="${ROOT}/${APP}.AppDir"

mkdir -p "$OUTDIR"
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin"

# --- 1) Locate your built binary ---
# Adjust this path to wherever your build produces the GUI executable.
# Common examples:
#   build/release/bin/xcash-wallet-gui
#   build/release/src/xcash-wallet-gui
BIN_CANDIDATES=(
  "${ROOT}/build/release/bin/${APP}"
  "${ROOT}/build/release/${APP}"
  "${ROOT}/build/release/src/${APP}"
)
BIN=""
for c in "${BIN_CANDIDATES[@]}"; do
  if [ -f "$c" ]; then BIN="$c"; break; fi
done
if [ -z "$BIN" ]; then
  echo "ERROR: Could not find built binary. Looked in:"
  printf '  - %s\n' "${BIN_CANDIDATES[@]}"
  exit 1
fi

echo "Using binary: $BIN"
cp -a "$BIN" "$APPDIR/usr/bin/${APP}"

# --- 2) Desktop file + icon ---
# Put a 256x256 or 512x512 PNG in: assets/xcash-wallet-gui.png
ICON_SRC="${ROOT}/tools/${APP}.png"
if [ ! -f "$ICON_SRC" ]; then
  echo "ERROR: Missing icon: $ICON_SRC"
  echo "Create assets/${APP}.png (256x256+)."
  exit 1
fi
cp -a "$ICON_SRC" "$APPDIR/${APP}.png"

cat > "$APPDIR/${APP}.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=XCash Wallet GUI
Exec=${APP}
Icon=${APP}
Categories=Finance;Network;
Terminal=false
EOF

# --- 3) AppRun launcher ---
cat > "$APPDIR/AppRun" <<'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "$0")")"
export LD_LIBRARY_PATH="$HERE/usr/lib:$HERE/usr/lib64:$LD_LIBRARY_PATH"
export QT_PLUGIN_PATH="$HERE/usr/plugins:$HERE/usr/lib/qt/plugins:$QT_PLUGIN_PATH"
export QML2_IMPORT_PATH="$HERE/usr/qml:$HERE/usr/lib/qt/qml:$QML2_IMPORT_PATH"
exec "$HERE/usr/bin/xcash-wallet-gui" "$@"
EOF
chmod +x "$APPDIR/AppRun"

# --- 4) Download linuxdeploy (once) ---
cd "$OUTDIR"
if [ ! -f linuxdeploy-${ARCH}.AppImage ]; then
  wget -O linuxdeploy-${ARCH}.AppImage \
    https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-${ARCH}.AppImage
  chmod +x linuxdeploy-${ARCH}.AppImage
fi

# Optional: Qt plugin helper (recommended for Qt apps)
if [ ! -f linuxdeploy-plugin-qt-${ARCH}.AppImage ]; then
  wget -O linuxdeploy-plugin-qt-${ARCH}.AppImage \
    https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-${ARCH}.AppImage
  chmod +x linuxdeploy-plugin-qt-${ARCH}.AppImage
fi

# --- 5) Bundle deps + Qt plugins, then build AppImage ---
export LINUXDEPLOY_OUTPUT=appimage

./linuxdeploy-${ARCH}.AppImage \
  --appdir "$APPDIR" \
  --executable "$APPDIR/usr/bin/${APP}" \
  --desktop-file "$APPDIR/${APP}.desktop" \
  --icon-file "$APPDIR/${APP}.png" \
  --plugin qt

# linuxdeploy outputs into current dir by default
echo "Output files in: $OUTDIR"
ls -lh "$OUTDIR" | sed -n '1,200p'
