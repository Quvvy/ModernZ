# One-time Anki setup for ModernZ sentence-first mining with mpvacious + optional Yomitan.
# Run: powershell -ExecutionPolicy Bypass -File "$env:APPDATA\mpv\portable_config\setup-anki-mining.ps1"
# Requires Anki to be open. If AnkiConnect is not installed yet, install add-on code 2055492159 from Anki first.

$ErrorActionPreference = 'Stop'

$AnkiConnectUrl = 'http://127.0.0.1:8765'
$AjtJapaneseAddonCode = '3918629684'

function Invoke-AnkiConnect {
    param([hashtable]$Body)

    $json = $Body | ConvertTo-Json -Depth 50 -Compress
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    $response = Invoke-WebRequest -Uri $AnkiConnectUrl -Method Post -Body $bytes -ContentType 'application/json; charset=utf-8' -UseBasicParsing
    $text = [System.Text.Encoding]::UTF8.GetString($response.RawContentStream.ToArray())
    if (-not $text) { $text = $response.Content }

    $resp = $text | ConvertFrom-Json
    if ($resp.error) { throw $resp.error }
    return $resp.result
}

Write-Host "=== ModernZ Anki mining setup ==="
Write-Host ""

try {
    $version = Invoke-AnkiConnect -Body @{ action = 'version'; version = 6 }
    Write-Host "AnkiConnect is running (version $version)."
} catch {
    Write-Host "AnkiConnect is not reachable at $AnkiConnectUrl."
    Write-Host ""
    Write-Host "Open Anki, then install AnkiConnect manually:"
    Write-Host "  Tools -> Add-ons -> Get Add-ons..."
    Write-Host "  Code: 2055492159"
    Write-Host ""
    Write-Host "Restart Anki after installing it, then run this script again."
    exit 1
}

Write-Host ""
Write-Host "Installing/updating AJT Japanese ($AjtJapaneseAddonCode) for furigana and pitch..."
try {
    $result = Invoke-AnkiConnect -Body @{
        action = 'installAddon'
        version = 6
        params = @{ code = $AjtJapaneseAddonCode }
    }
    if ($result -eq $true) {
        Write-Host "AJT Japanese installed or updated."
    } else {
        Write-Host "AJT Japanese install returned: $result"
    }
} catch {
    Write-Host "WARN: Could not install AJT Japanese automatically."
    Write-Host "Install it manually in Anki with add-on code: $AjtJapaneseAddonCode"
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$cardSetup = Join-Path $scriptDir 'configure-mining-cards.ps1'

Write-Host ""
if (Test-Path $cardSetup) {
    Write-Host "Creating/updating ModernZ Mining Sentence note type..."
    & $cardSetup
} else {
    Write-Host "WARN: configure-mining-cards.ps1 was not found next to this script."
    Write-Host "Copy it to: $scriptDir"
}

Write-Host ""
Write-Host "=== Done ==="
Write-Host ""
Write-Host "Use these targets in mpvacious/Yomitan:"
Write-Host "  Deck:  Anime::Mining"
Write-Host "  Model: ModernZ Mining Sentence"
Write-Host ""
Write-Host "Daily workflow:"
Write-Host "  1. Keep Anki open."
Write-Host "  2. Play anime in mpv with Japanese subtitles."
Write-Host "  3. Toggle English secondary subtitles with Ctrl+v when available."
Write-Host "  4. Press Ctrl+n or use the ModernZ mining button to make a sentence card."
