#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

swift build -c release

APP="$ROOT/TermDesk.app"
BIN="$ROOT/.build/release/TermDesk"
MACOS="$APP/Contents/MacOS"
RESOURCES="$APP/Contents/Resources"

mkdir -p "$MACOS" "$RESOURCES"
cp "$BIN" "$MACOS/TermDesk"
chmod +x "$MACOS/TermDesk"

cat > "$APP/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>zh_CN</string>
    <key>CFBundleExecutable</key>
    <string>TermDesk</string>
    <key>CFBundleIdentifier</key>
    <string>com.qr.termdesk</string>
    <key>CFBundleName</key>
    <string>TermDesk</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>0.2.0</string>
    <key>CFBundleVersion</key>
    <string>2</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

codesign --force --sign - "$APP/Contents/MacOS/TermDesk" 2>/dev/null || true
codesign --force --deep --sign - "$APP" 2>/dev/null || true

echo "已生成 $APP"
echo "运行: open \"$APP\""
