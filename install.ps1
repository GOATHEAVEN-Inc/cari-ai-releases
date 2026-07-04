# 카리AI CLI 설치 스크립트 (Windows PowerShell)
#   irm https://goatheaven-inc.github.io/cari-ai-releases/install.ps1 | iex
$ErrorActionPreference = "Stop"

$Repo = "GOATHEAVEN-Inc/cari-ai-releases"
$CariHome = Join-Path $env:USERPROFILE ".cari"
$BinDir = Join-Path $CariHome "bin"
$Url = "https://github.com/$Repo/releases/latest/download/cari.mjs"

function Info($m) { Write-Host "▸ $m" -ForegroundColor Cyan }
function Warn($m) { Write-Host "! $m" -ForegroundColor Yellow }

# 1) Node 확인 (v18+)
$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
  Write-Host "✖ Node.js가 필요합니다 (v18+). https://nodejs.org" -ForegroundColor Red
  exit 1
}
$major = (& node -e "process.stdout.write(process.versions.node.split('.')[0])")
if ([int]$major -lt 18) {
  Write-Host "✖ Node.js 18 이상이 필요합니다 (현재 $(node -v))." -ForegroundColor Red
  exit 1
}

# 2) 다운로드
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
Info "카리AI CLI 다운로드 중…"
Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile (Join-Path $BinDir "cari.mjs")

# 3) 런처(cari.cmd) 생성
$launcher = Join-Path $BinDir "cari.cmd"
"@echo off`r`nnode `"%~dp0cari.mjs`" %*" | Set-Content -Encoding ASCII $launcher

# 4) PATH 추가(사용자 범위)
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$BinDir*") {
  [Environment]::SetEnvironmentVariable("Path", "$userPath;$BinDir", "User")
  Warn "PATH에 $BinDir 추가됨. 새 터미널을 열어야 적용됩니다."
}

Info "설치 완료. 새 터미널에서 실행:  cari"
Info "서버 주소 설정(선택):  cari config set api https://<서버주소>"
