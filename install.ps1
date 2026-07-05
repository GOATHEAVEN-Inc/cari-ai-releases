# 카리AI CLI 설치 스크립트 (Windows PowerShell) — 다국어(로캘 자동 감지)
#   irm https://goatheaven-inc.github.io/cari-ai-releases/install.ps1 | iex
# 언어 강제:  $env:CARI_LANG="en"; irm ... | iex
$ErrorActionPreference = "Stop"

$Repo = "GOATHEAVEN-Inc/cari-ai-releases"
$CariHome = Join-Path $env:USERPROFILE ".cari"
$BinDir = Join-Path $CariHome "bin"
$Url = "https://github.com/$Repo/releases/latest/download/cari.mjs"

# ── 로캘 감지 (ko/ja/zh/es/그외 en) ──────────────────────────
$lc = $env:CARI_LANG
if (-not $lc) { try { $lc = (Get-Culture).TwoLetterISOLanguageName } catch { $lc = "en" } }
$L = switch -Wildcard ($lc) { "ko*" { "ko" } "ja*" { "ja" } "zh*" { "zh" } "es*" { "es" } default { "en" } }

function M($ko, $en, $ja, $zh, $es) {
  switch ($L) { "ko" { $ko } "ja" { $ja } "zh" { $zh } "es" { $es } default { $en } }
}
function Info($m) { Write-Host "▸ $m" -ForegroundColor Cyan }
function Warn($m) { Write-Host "! $m" -ForegroundColor Yellow }

# 1) Node 확인 (v18+)
$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
  Write-Host ("✖ " + (M "Node.js가 필요합니다 (v18+). https://nodejs.org" `
    "Node.js is required (v18+). https://nodejs.org" `
    "Node.js が必要です (v18+)。https://nodejs.org" `
    "需要 Node.js (v18+)。https://nodejs.org" `
    "Se requiere Node.js (v18+). https://nodejs.org")) -ForegroundColor Red
  exit 1
}
$major = (& node -e "process.stdout.write(process.versions.node.split('.')[0])")
if ([int]$major -lt 18) {
  Write-Host ("✖ " + (M "Node.js 18 이상이 필요합니다 (현재 $(node -v))." `
    "Node.js 18+ is required (current $(node -v))." `
    "Node.js 18 以上が必要です (現在 $(node -v))。" `
    "需要 Node.js 18 及以上 (当前 $(node -v))。" `
    "Se requiere Node.js 18+ (actual $(node -v)).")) -ForegroundColor Red
  exit 1
}

# 2) 다운로드
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
Info (M "카리AI CLI 다운로드 중…" "Downloading CARI AI CLI…" "カリAI CLI をダウンロード中…" "正在下载卡里AI CLI…" "Descargando CARI AI CLI…")
Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile (Join-Path $BinDir "cari.mjs")

# 3) 런처(cari.cmd) 생성
$launcher = Join-Path $BinDir "cari.cmd"
"@echo off`r`nnode `"%~dp0cari.mjs`" %*" | Set-Content -Encoding ASCII $launcher

# 4) PATH 추가(사용자 범위)
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$BinDir*") {
  [Environment]::SetEnvironmentVariable("Path", "$userPath;$BinDir", "User")
  Warn (M "PATH에 $BinDir 추가됨. 새 터미널을 열어야 적용됩니다." `
    "Added $BinDir to PATH. Open a new terminal to apply." `
    "$BinDir を PATH に追加しました。新しいターミナルで有効になります。" `
    "已将 $BinDir 添加到 PATH。请打开新终端以生效。" `
    "Se añadió $BinDir al PATH. Abre una terminal nueva para aplicarlo.")
}

Info (M "설치 완료. 새 터미널에서 실행:  cari" "Done. Run in a new terminal:  cari" "完了。新しいターミナルで実行:  cari" "完成。在新终端中运行:  cari" "Listo. Ejecuta en una terminal nueva:  cari")
Info (M "첫 실행 시 언어 선택 마법사가 열립니다." "On first run a language wizard opens." "初回実行時に言語選択ウィザードが開きます。" "首次运行时会打开语言选择向导。" "En el primer inicio se abre el asistente de idioma.")
