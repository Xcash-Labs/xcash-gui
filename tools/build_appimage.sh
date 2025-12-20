#!/usr/bin/env bash
set -euo pipefail

APP=xcash-wallet-gui
ARCH=x86_64

ROOT="$(pwd)"
SRC="${ROOT}/${APP}"                 # your staged folder
OUTDIR="${ROOT}/dist"
APPDIR="${OUTDIR}/${APP}.AppDir"     # clean build AppDir

mkdir -p "$OUTDIR"
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin"

# --- 0) Validate staged input ---
if [ ! -d "$SRC" ]; then
  echo "ERROR: Missing staged folder: $SRC"
  echo "Run this script from the directory that contains the '$APP/' folder."
  exit 1
fi

if [ ! -f "$SRC/$APP" ]; then
  echo "ERROR: Missing executable: $SRC/$APP"
  exit 1
fi

if [ ! -d "$SRC/usr" ]; then
  echo "ERROR: Missing staged usr/: $SRC/usr"
  exit 1
fi

ICON_SRC="$SRC/images/${APP}.png"
if [ ! -f "$ICON_SRC" ]; then
  echo "ERROR: Missing icon: $ICON_SRC"
  exit 1
fi

# --- 1) Copy staged content into clean AppDir ---
# Copy entire usr tree (includes your plugins/qml/libs)
cp -a "$SRC/usr" "$APPDIR/"

# Put binary where AppDir expects it
cp -a "$SRC/$APP" "$APPDIR/usr/bin/$APP"

# Optional extras + license
if [ -d "$SRC/extras" ]; then
  cp -a "$SRC/extras" "$APPDIR/"
fi
if [ -f "$SRC/LICENSE" ]; then
  cp -a "$SRC/LICENSE" "$APPDIR/"
fi

# Copy icon to AppDir root with the right name
cp -a "$ICON_SRC" "$APPDIR/${APP}.png"

# --- 2) Desktop file ---
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
cat > "$APPDIR/AppRun" <<EOF
#!/bin/sh
HERE="\$(dirname "\$(readlink -f "\$0")")"

export LD_LIBRARY_PATH="\$HERE/usr/lib:\$HERE/usr/lib64:\$HERE/usr/local/lib:\$LD_LIBRARY_PATH"
export QT_PLUGIN_PATH="\$HERE/usr/plugins:\$HERE/usr/lib/qt/plugins:\$QT_PLUGIN_PATH"
export QML2_IMPORT_PATH="\$HERE/usr/qml:\$HERE/usr/lib/qt/qml:\$QML2_IMPORT_PATH"

exec "\$HERE/usr/bin/${APP}" "\$@"
EOF
chmod +x "$APPDIR/AppRun"

# --- 4) Download linuxdeploy (once) ---
cd "$OUTDIR"
if [ ! -f linuxdeploy-${ARCH}.AppImage ]; then
  wget -O linuxdeploy-${ARCH}.AppImage \
    https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-${ARCH}.AppImage
  chmod +x linuxdeploy-${ARCH}.AppImage
fi

# --- 5) Build AppImage (NO --plugin qt) ---
export LINUXDEPLOY_OUTPUT=appimage

./linuxdeploy-${ARCH}.AppImage \
  --appdir "$APPDIR" \
  --desktop-file "$APPDIR/${APP}.desktop" \
  --icon-file "$APPDIR/${APP}.png"

echo "Output files in: $OUTDIR"
ls -lh "$OUTDIR" | sed -n '1,200p'