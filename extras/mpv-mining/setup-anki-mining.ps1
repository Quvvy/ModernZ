# One-time Anki setup for mpvacious sentence mining with Seanime + Jimaku.
# Run: powershell -ExecutionPolicy Bypass -File "$env:APPDATA\mpv\portable_config\setup-anki-mining.ps1"

$ErrorActionPreference = 'Stop'

$AnkiExe = @(
    "$env:LOCALAPPDATA\Programs\Anki\anki.exe",
    "${env:ProgramFiles}\Anki\anki.exe",
    "${env:ProgramFiles(x86)}\Anki\anki.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $AnkiExe) {
    Write-Host "Anki not found. Install with: winget install Anki.Anki"
    exit 1
}

Write-Host "Using Anki: $AnkiExe"
Write-Host "Installing AnkiConnect (2055492159)..."
& $AnkiExe --addon install 2055492159

Write-Host "Installing AJT Japanese sentences note type (1557722832)..."
& $AnkiExe --addon install 1557722832

Write-Host ""
Write-Host "Done. Next steps:"
Write-Host "  1. Open Anki and restart if prompted"
Write-Host "  2. Verify http://127.0.0.1:8765 shows AnkiConnect version JSON"
Write-Host "  3. Open Anki before mining in mpv"
Write-Host "  4. Play anime in Seanime, then in mpv press:"
Write-Host "       a  = mpvacious menu"
Write-Host "       g  = quick card from current subtitle"
Write-Host "       Ctrl+n = export note to deck Anime::Mining"
