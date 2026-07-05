#!/bin/sh
# 카리AI CLI 설치 스크립트 (macOS / Linux) — 다국어(로캘 자동 감지)
#   curl -fsSL https://goatheaven-inc.github.io/cari-ai-releases/install.sh | sh
# 언어 강제: CARI_LANG=en curl ... | sh
set -e

REPO="GOATHEAVEN-Inc/cari-ai-releases"
CARI_HOME="${CARI_HOME:-$HOME/.cari}"
BIN_DIR="$CARI_HOME/bin"
LAUNCHER="$BIN_DIR/cari"
URL="https://github.com/$REPO/releases/latest/download/cari.mjs"

# ── 로캘 감지 (ko/ja/zh/es/그외 en) ──────────────────────────
LC="${CARI_LANG:-${LANG:-${LC_ALL:-en}}}"
case "$LC" in
  ko*) L=ko ;; ja*) L=ja ;; zh*) L=zh ;; es*) L=es ;; *) L=en ;;
esac

msg() { # msg <ko> <en> <ja> <zh> <es>
  case "$L" in
    ko) printf "%s" "$1" ;; ja) printf "%s" "$3" ;;
    zh) printf "%s" "$4" ;; es) printf "%s" "$5" ;; *) printf "%s" "$2" ;;
  esac
}

info() { printf "\033[38;5;39m▸\033[0m %s\n" "$1"; }
warn() { printf "\033[33m!\033[0m %s\n" "$1"; }
err()  { printf "\033[31m✖\033[0m %s\n" "$1"; }

# 1) Node 확인 (v18+)
if ! command -v node >/dev/null 2>&1; then
  err "$(msg \
    "Node.js가 필요합니다 (v18+). https://nodejs.org 에서 설치 후 다시 실행하세요." \
    "Node.js is required (v18+). Install it from https://nodejs.org and retry." \
    "Node.js が必要です (v18+)。https://nodejs.org からインストール後、再実行してください。" \
    "需要 Node.js (v18+)。请从 https://nodejs.org 安装后重试。" \
    "Se requiere Node.js (v18+). Instálalo desde https://nodejs.org y reinténtalo.")"
  exit 1
fi
NODE_MAJOR=$(node -e 'process.stdout.write(process.versions.node.split(".")[0])')
if [ "$NODE_MAJOR" -lt 18 ]; then
  err "$(msg \
    "Node.js 18 이상이 필요합니다 (현재 $(node -v))." \
    "Node.js 18+ is required (current $(node -v))." \
    "Node.js 18 以上が必要です (現在 $(node -v))。" \
    "需要 Node.js 18 及以上 (当前 $(node -v))。" \
    "Se requiere Node.js 18+ (actual $(node -v)).")"
  exit 1
fi

# 2) 다운로드
mkdir -p "$BIN_DIR"
info "$(msg "카리AI CLI 다운로드 중…" "Downloading CARI AI CLI…" "カリAI CLI をダウンロード中…" "正在下载卡里AI CLI…" "Descargando CARI AI CLI…")"
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$URL" -o "$BIN_DIR/cari.mjs"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$BIN_DIR/cari.mjs" "$URL"
else
  err "$(msg "curl 또는 wget이 필요합니다." "curl or wget is required." "curl または wget が必要です。" "需要 curl 或 wget。" "Se requiere curl o wget.")"
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
    info "$(msg "설치 완료 → $d/cari" "Installed → $d/cari" "インストール完了 → $d/cari" "安装完成 → $d/cari" "Instalado → $d/cari")"
    break
  fi
done

echo ""
if [ "$LINKED" -eq 1 ]; then
  info "$(msg "이제 터미널에서 실행하세요:  cari" "Now run it in your terminal:  cari" "ターミナルで実行してください:  cari" "现在在终端中运行:  cari" "Ahora ejecútalo en tu terminal:  cari")"
else
  warn "$(msg "PATH 추가가 필요합니다:" "Add it to your PATH:" "PATH への追加が必要です:" "需要添加到 PATH:" "Añádelo a tu PATH:")"
  echo "    export PATH=\"$BIN_DIR:\$PATH\""
  echo "    sudo ln -sf $LAUNCHER /usr/local/bin/cari"
  echo ""
  info "$(msg "또는 바로 실행:  $LAUNCHER" "Or run directly:  $LAUNCHER" "または直接実行:  $LAUNCHER" "或直接运行:  $LAUNCHER" "O ejecuta directamente:  $LAUNCHER")"
fi
echo ""
info "$(msg \
  "첫 실행 시 언어 선택 마법사가 열립니다.  cari" \
  "On first run a language wizard opens.  cari" \
  "初回実行時に言語選択ウィザードが開きます。  cari" \
  "首次运行时会打开语言选择向导。  cari" \
  "En el primer inicio se abre el asistente de idioma.  cari")"
