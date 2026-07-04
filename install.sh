#!/bin/sh
# 카리AI CLI 설치 스크립트 (macOS / Linux)
#   curl -fsSL https://goatheaven-inc.github.io/cari-ai-releases/install.sh | sh
set -e

REPO="GOATHEAVEN-Inc/cari-ai-releases"
CARI_HOME="${CARI_HOME:-$HOME/.cari}"
BIN_DIR="$CARI_HOME/bin"
LAUNCHER="$BIN_DIR/cari"
URL="https://github.com/$REPO/releases/latest/download/cari.mjs"

info() { printf "\033[38;5;43m▸\033[0m %s\n" "$1"; }
warn() { printf "\033[33m!\033[0m %s\n" "$1"; }
err()  { printf "\033[31m✖\033[0m %s\n" "$1"; }

# 1) Node 확인 (v18+)
if ! command -v node >/dev/null 2>&1; then
  err "Node.js가 필요합니다 (v18+)."
  echo "  https://nodejs.org 에서 설치한 뒤 다시 실행하세요."
  exit 1
fi
NODE_MAJOR=$(node -e 'process.stdout.write(process.versions.node.split(".")[0])')
if [ "$NODE_MAJOR" -lt 18 ]; then
  err "Node.js 18 이상이 필요합니다 (현재 $(node -v))."
  exit 1
fi

# 2) 다운로드
mkdir -p "$BIN_DIR"
info "카리AI CLI 다운로드 중…"
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$URL" -o "$BIN_DIR/cari.mjs"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$BIN_DIR/cari.mjs" "$URL"
else
  err "curl 또는 wget이 필요합니다."
  exit 1
fi

# 3) 런처 생성
cat > "$LAUNCHER" <<EOF
#!/bin/sh
exec node "$BIN_DIR/cari.mjs" "\$@"
EOF
chmod +x "$LAUNCHER"

# 4) PATH 연결
LINKED=0
for d in /usr/local/bin "$HOME/.local/bin"; do
  if [ -d "$d" ] && [ -w "$d" ]; then
    ln -sf "$LAUNCHER" "$d/cari"
    LINKED=1
    info "설치 완료 → $d/cari"
    break
  fi
done

echo ""
if [ "$LINKED" -eq 1 ]; then
  info "이제 터미널에서 실행하세요:  \033[1mcari\033[0m"
else
  warn "PATH에 추가가 필요합니다. 아래 중 하나를 실행하세요:"
  echo "    export PATH=\"$BIN_DIR:\$PATH\"    # 현재 셸"
  echo "    sudo ln -sf $LAUNCHER /usr/local/bin/cari   # 전역"
  echo ""
  info "또는 바로 실행:  \033[1m$LAUNCHER\033[0m"
fi
echo ""
info "서버 주소 설정(선택):  cari config set api https://<서버주소>"
