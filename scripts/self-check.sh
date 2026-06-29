#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PASS=0
FAIL=0
WARN=0

ok()   { echo "  ✓ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }
warn() { echo "  ⚠ $1"; WARN=$((WARN + 1)); }

echo "=== TermDesk 自检 ==="
echo ""

echo "[1/5] 同级 SysPeek"
if [[ -d "$ROOT/../syspeek/Package.swift" || -f "$ROOT/../syspeek/Package.swift" ]]; then
  ok "../syspeek 存在"
else
  fail "../syspeek 不存在（SPM 路径依赖）"
fi

echo "[2/5] Swift 构建"
if swift build -c release >/dev/null 2>&1; then
  ok "swift build -c release"
else
  fail "swift build -c release"
fi

echo "[3/5] 打包"
if ./scripts/package-app.sh >/dev/null 2>&1; then
  ok "package-app.sh"
else
  fail "package-app.sh"
fi

APP="$ROOT/TermDesk.app"
echo "[4/5] Bundle"
[[ -x "$APP/Contents/MacOS/TermDesk" ]] && ok "TermDesk.app 可执行" || fail "TermDesk.app 可执行"

echo "[5/5] qr CLI"
if command -v qr >/dev/null 2>&1 || [[ -x /opt/anaconda3/bin/qr ]]; then
  ok "qr 命令可用"
else
  warn "qr 未在 PATH（QR Tab 功能受限）"
fi

echo ""
echo "=== 结果：${PASS} 通过 / ${WARN} 警告 / ${FAIL} 失败 ==="
[[ "$FAIL" -eq 0 ]]
