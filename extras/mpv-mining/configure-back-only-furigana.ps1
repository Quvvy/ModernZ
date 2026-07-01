# Compatibility wrapper for the old script name.
# The ModernZ mining card setup now uses a dedicated note type:
#   ModernZ Mining Sentence

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$newScript = Join-Path $scriptDir 'configure-mining-cards.ps1'

Write-Host "configure-back-only-furigana.ps1 has been replaced by configure-mining-cards.ps1."
Write-Host "This wrapper will run the new ModernZ mining card setup."
Write-Host ""

& $newScript
