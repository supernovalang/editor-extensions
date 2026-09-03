# install_ide.ps1
# Interactive IDE setup script for PowerShell
# Presents a menu allowing the user to select one or more IDEs and the Default Snovalang LSP.
# The selection is done by entering space‑separated numbers and confirming with Enter.

# Define the options (index starts at 1)
$options = @(
    @{ Id = 1; Tag = "default"; Label = "Default Snovalang LSP" }
    @{ Id = 2; Tag = "vscode";  Label = "Visual Studio Code" }
    @{ Id = 3; Tag = "zed";     Label = "Zed" }
)

function Show-Menu {
    Write-Host "Choose a setup for your IDE:" -ForegroundColor Cyan
    Write-Host "-- Toggle options using Space (enter numbers separated by spaces) --"
    Write-Host "-- Submit on Enter --`n"
    foreach ($opt in $options) {
        Write-Host "[$($opt.Id)] $($opt.Label)"
    }
    Write-Host "`nEnter your choice(s): " -NoNewline
    $input = Read-Host
    return $input
}

$input = Show-Menu
if ([string]::IsNullOrWhiteSpace($input)) {
    Write-Host "No option selected. Exiting."
    exit 0
}

# Parse numbers
$selectedIds = $input -split '\s+' | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ }
$selectedTags = @()
foreach ($id in $selectedIds) {
    $match = $options | Where-Object { $_.Id -eq $id }
    if ($null -ne $match) { $selectedTags += $match.Tag }
}

if ($selectedTags.Count -eq 0) {
    Write-Host "No valid option selected. Exiting."
    exit 0
}

function Print-Status($tag, $label) {
    if ($selectedTags -contains $tag) {
        Write-Host "(x) $label"
    } else {
        Write-Host "( ) $label"
    }
}

Write-Host "You selected:`n"
Print-Status "default" "Default Snovalang LSP"
Print-Status "vscode"  "Visual Studio Code"
Print-Status "zed"     "Zed"

# Placeholder for actual installation logic
if ($selectedTags -contains "default") {
    Write-Host "Installing Default Snovalang LSP..." -ForegroundColor Cyan

    $url    = "https://github.com/supernovalang/snova-lsp/archive/refs/heads/master.zip"
    $zip    = "$env:TEMP\snova-lsp.zip"
    $tmpDir = "$env:TEMP\snova-lsp-extract"
    $installDir = "$env:LOCALAPPDATA\snova-lsp\bin"

    Write-Host "Downloading LSP from $url..."
    Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing

    Write-Host "Extracting LSP..."
    if (Test-Path $tmpDir) { Remove-Item -Recurse -Force $tmpDir }
    Expand-Archive -Path $zip -DestinationPath $tmpDir -Force
    Remove-Item $zip

    # O zip do GitHub extrai para uma subpasta snova-lsp-master/
    $extracted = Get-ChildItem $tmpDir -Directory | Select-Object -First 1
    if (-not $extracted) {
        Write-Host "ERROR: Could not find extracted folder in $tmpDir" -ForegroundColor Red
        exit 1
    }

    # Copia para o diretório de instalação (sem admin)
    if (Test-Path $installDir) { Remove-Item -Recurse -Force $installDir }
    New-Item -ItemType Directory -Force -Path $installDir | Out-Null
    Copy-Item -Recurse -Force "$($extracted.FullName)\*" $installDir
    Remove-Item -Recurse -Force $tmpDir

    Write-Host "Snovalang LSP installed to $installDir" -ForegroundColor Green

    # Adiciona ao PATH do usuário (sem admin)
    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($userPath -notlike "*$installDir*") {
        [Environment]::SetEnvironmentVariable("PATH", "$userPath;$installDir", "User")
        Write-Host "Added $installDir to user PATH." -ForegroundColor Green
        Write-Host "Restart your terminal for PATH changes to take effect." -ForegroundColor Yellow
    }
}
if ($selectedTags -contains "vscode") {
    Write-Host "Installing Snovalang extension for VS Code..."
    # Example: code --install-extension snovalang.snovalang
}
if ($selectedTags -contains "zed") {
    Write-Host "Installing Snovalang extension for Zed..." -ForegroundColor Cyan

    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $zedExtensionSrc = Join-Path $scriptDir "zed"

    # Determine Zed extensions directory based on OS
    $zedRoot = if ($env:LOCALAPPDATA) { "$env:LOCALAPPDATA\Zed" } else { "$env:APPDATA\Zed" }
    $zedExtDir = "$zedRoot\extensions\installed\snovalang"
    $zedBinDir = "$zedRoot\tools\bin"

    if (-not (Test-Path $zedExtensionSrc)) {
        Write-Host "ERROR: Zed extension source not found at: $zedExtensionSrc" -ForegroundColor Red
        exit 1
    }

    # Remove previous installation if exists
    if (Test-Path $zedExtDir) {
        Remove-Item -Recurse -Force $zedExtDir
        Write-Host "Removed previous Zed extension installation."
    }

    # Copy extension files to Zed extensions directory
    New-Item -ItemType Directory -Force -Path (Split-Path $zedExtDir) | Out-Null
    if (Test-Path $zedExtDir) { Remove-Item -Recurse -Force $zedExtDir }
    Copy-Item -Recurse -Force $zedExtensionSrc $zedExtDir
    New-Item -ItemType Directory -Force -Path $zedBinDir | Out-Null
    $lspSource = Join-Path $scriptDir "..\snova-lsp\tools\bin\snova-lsp.exe"
    if (-not (Test-Path $lspSource)) {
        $lspSource = Join-Path $scriptDir "..\snova-lsp\build\snova-lsp.exe"
    }
    if (Test-Path $lspSource) {
        $installedLsp = Join-Path $zedBinDir "snova-lsp.exe"
        if (Test-Path $installedLsp) { Remove-Item -Force $installedLsp }
        Copy-Item -Force $lspSource $installedLsp
        $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        $pathEntries = @($userPath -split ';' | Where-Object { $_ })
        if ($pathEntries -notcontains $zedBinDir) {
            [Environment]::SetEnvironmentVariable("PATH", (($pathEntries + $zedBinDir) -join ';'), "User")
            Write-Host "Added $zedBinDir to the user PATH." -ForegroundColor Green
        }
    } else {
        Write-Host "WARNING: snova-lsp.exe was not found; build snova-lsp first." -ForegroundColor Yellow
    }
    Write-Host "Snovalang Zed extension installed to: $zedExtDir" -ForegroundColor Green
    Write-Host ""
    Write-Host "IMPORTANT: Restart Zed and run 'zed: reload extensions' (Ctrl+Shift+P) to activate." -ForegroundColor Yellow
}

exit 0
