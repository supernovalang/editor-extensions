# build.ps1 — Compila a extensão Zed para Snovalang
# Gera o arquivo extension.wasm necessário para instalação.
#
# Uso:
#   .\build.ps1              # Build release (padrão)
#   .\build.ps1 -Debug       # Build debug
#   .\build.ps1 -Install     # Build + copia para Zed extensions

param(
    [switch]$Debug,
    [switch]$Install
)

$ErrorActionPreference = "Stop"

# Verifica se rustup está instalado
if (-not (Get-Command rustup -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: rustup not found. Install from https://rustup.rs" -ForegroundColor Red
    exit 1
}

# Garante que o target WASM está instalado
$wasmTarget = "wasm32-wasip1"
$installed = rustup target list --installed 2>&1
if ($installed -notmatch $wasmTarget) {
    Write-Host "Installing WASM target $wasmTarget..." -ForegroundColor Cyan
    rustup target add $wasmTarget
}

# Garante que o toolchain GNU está disponível (necessário no Windows sem Windows SDK completo)
$gnuToolchain = "stable-x86_64-pc-windows-gnu"
$toolchains = rustup toolchain list 2>&1
if ($toolchains -notmatch "x86_64-pc-windows-gnu") {
    Write-Host "Installing GNU toolchain (needed on Windows to avoid msvcrt.lib error)..." -ForegroundColor Cyan
    rustup toolchain install $gnuToolchain --target $wasmTarget
} else {
    # Garante que o target WASM está no toolchain GNU
    rustup target add $wasmTarget --toolchain $gnuToolchain 2>&1 | Out-Null
}

# Build
$profile = if ($Debug) { "debug" } else { "release" }
$releaseFlag = if ($Debug) { "" } else { "--release" }

Write-Host "Building Snovalang Zed extension ($profile)..." -ForegroundColor Cyan
$buildCmd = "cargo +$gnuToolchain build $releaseFlag"
Invoke-Expression $buildCmd
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit $LASTEXITCODE
}

# Copia o .wasm para a raiz (onde o Zed espera encontrar)
$wasmSrc = "target\$wasmTarget\$profile\zed_snovalang.wasm"
$wasmDst = "extension.wasm"
Copy-Item -Force $wasmSrc $wasmDst
Write-Host "extension.wasm updated ($([Math]::Round((Get-Item $wasmDst).Length / 1KB)) KB)" -ForegroundColor Green

if ($Install) {
    $zedExtDir = "$env:APPDATA\Zed\extensions\installed\snovalang"
    $srcDir = Split-Path -Parent $MyInvocation.MyCommand.Path

    if (Test-Path $zedExtDir) {
        Remove-Item -Recurse -Force $zedExtDir
    }
    New-Item -ItemType Directory -Force -Path (Split-Path $zedExtDir) | Out-Null
    Copy-Item -Recurse -Force $srcDir $zedExtDir
    Write-Host "Extension installed to: $zedExtDir" -ForegroundColor Green
    Write-Host "Restart Zed and run 'zed: reload extensions' to activate." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done! To install in Zed, run: .\build.ps1 -Install" -ForegroundColor Cyan
