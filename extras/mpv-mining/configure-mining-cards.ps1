# Configure the ModernZ sentence-first mining note type.
# Run: powershell -ExecutionPolicy Bypass -File "$env:APPDATA\mpv\portable_config\configure-mining-cards.ps1"
# Requires Anki running with AnkiConnect.

$ErrorActionPreference = 'Stop'

$DeckName = 'Anime::Mining'
$NoteType = 'ModernZ Mining Sentence'
$AnkiConnectUrl = 'http://127.0.0.1:8765'

$Fields = @(
    'SentKanji',
    'SentFurigana',
    'SentEng',
    'Image',
    'SentAudio',
    'VocabKanji',
    'VocabFurigana',
    'VocabDef',
    'VocabPitchPattern',
    'VocabPitchNum',
    'VocabAudio',
    'Notes'
)

$FrontTemplate = @'
<main class="mz-card mz-front">
  <section class="mz-sentence">{{SentKanji}}</section>
</main>
'@

$BackTemplate = @'
<main class="mz-card mz-back">
  <section class="mz-sentence mz-answer">
    {{#SentFurigana}}{{furigana:SentFurigana}}{{/SentFurigana}}
    {{^SentFurigana}}{{SentKanji}}{{/SentFurigana}}
  </section>

  {{#SentEng}}
  <section class="mz-translation">{{SentEng}}</section>
  {{/SentEng}}

  {{#Image}}
  <section class="mz-image">{{Image}}</section>
  {{/Image}}

  {{#SentAudio}}
  <section class="mz-audio">{{SentAudio}}</section>
  {{/SentAudio}}

  {{#VocabKanji}}
  <section class="mz-vocab">
    <div class="mz-vocab-word">{{VocabKanji}}</div>
    {{#VocabFurigana}}<div class="mz-vocab-reading">{{furigana:VocabFurigana}}</div>{{/VocabFurigana}}
    {{#VocabDef}}<div class="mz-vocab-def">{{VocabDef}}</div>{{/VocabDef}}
    {{#VocabPitchPattern}}<div class="mz-vocab-pitch">{{VocabPitchPattern}}</div>{{/VocabPitchPattern}}
  </section>
  {{/VocabKanji}}

  {{#Notes}}
  <section class="mz-notes">{{Notes}}</section>
  {{/Notes}}
</main>
'@

$CardCss = @'
.card {
  margin: 0;
  padding: 0;
  background: #111418;
  color: #f5f1e8;
  font-family: "Noto Sans JP", "Yu Gothic UI", "Hiragino Sans", "Segoe UI", sans-serif;
  font-size: 22px;
  line-height: 1.55;
  text-align: center;
}

.mz-card {
  box-sizing: border-box;
  width: min(760px, calc(100vw - 32px));
  min-height: min(560px, calc(100vh - 32px));
  margin: 0 auto;
  padding: 32px 24px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 20px;
}

.mz-sentence {
  font-size: clamp(30px, 6vw, 48px);
  font-weight: 650;
  line-height: 1.5;
  letter-spacing: 0;
  text-wrap: balance;
}

.mz-answer {
  font-size: clamp(25px, 4.8vw, 38px);
}

.mz-translation {
  color: #d9e6ff;
  font-size: clamp(19px, 3.6vw, 25px);
  line-height: 1.45;
}

.mz-image img {
  display: block;
  width: min(100%, 680px);
  max-height: 42vh;
  object-fit: contain;
  margin: 0 auto;
  border-radius: 8px;
  box-shadow: 0 18px 42px rgba(0, 0, 0, 0.32);
}

.mz-audio {
  display: flex;
  justify-content: center;
  min-height: 32px;
}

.mz-audio .soundLink,
.mz-audio a {
  color: #ffffff;
  background: #2f7df6;
  border-radius: 999px;
  padding: 7px 14px;
  text-decoration: none;
}

.mz-vocab,
.mz-notes {
  margin: 4px auto 0;
  width: min(100%, 620px);
  padding-top: 16px;
  border-top: 1px solid rgba(255, 255, 255, 0.16);
  color: #c8d0dc;
  font-size: 17px;
  line-height: 1.45;
}

.mz-vocab-word {
  color: #ffffff;
  font-size: 22px;
  font-weight: 700;
}

.mz-vocab-reading,
.mz-vocab-pitch {
  color: #aeb8c7;
}

.mz-vocab-def {
  margin-top: 6px;
}

rt {
  opacity: 0;
  transition: opacity 120ms ease;
}

ruby:hover rt,
.card:hover rt {
  opacity: 1;
}

@media (max-width: 520px) {
  .mz-card {
    width: calc(100vw - 20px);
    padding: 24px 14px;
    gap: 16px;
  }

  .mz-image img {
    max-height: 34vh;
  }
}
'@

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

function Find-AjtJapaneseConfig {
    $addonsRoot = Join-Path $env:APPDATA 'Anki2\addons21'
    if (-not (Test-Path $addonsRoot)) { return $null }

    foreach ($dir in Get-ChildItem $addonsRoot -Directory) {
        $configPath = Join-Path $dir.FullName 'config.json'
        if (-not (Test-Path $configPath)) { continue }
        try {
            $cfg = Get-Content $configPath -Raw | ConvertFrom-Json
            if ($cfg.profiles -and (Test-Path (Join-Path $dir.FullName 'mecab_controller'))) {
                return @{ Path = $configPath; Config = $cfg }
            }
        } catch { }
    }
    return $null
}

function Set-AjtJapaneseProfiles {
    param($Config)

    $profiles = @(
        @{
            name = 'ModernZ sentence furigana'
            note_type = $NoteType
            source = 'SentKanji'
            destination = 'SentFurigana'
            mode = 'furigana'
            split_morphemes = $true
            triggered_by = 'focus_lost,toolbar_button,note_added,bulk_add'
            overwrite_destination = $false
            color_code_pitch = ''
        },
        @{
            name = 'ModernZ vocab furigana'
            note_type = $NoteType
            source = 'VocabKanji'
            destination = 'VocabFurigana'
            mode = 'furigana'
            split_morphemes = $false
            triggered_by = 'focus_lost,toolbar_button,note_added,bulk_add'
            overwrite_destination = $false
            color_code_pitch = ''
        },
        @{
            name = 'ModernZ vocab pitch'
            note_type = $NoteType
            source = 'VocabKanji'
            destination = 'VocabPitchPattern'
            mode = 'pitch'
            split_morphemes = $false
            output_format = 'html'
            triggered_by = 'focus_lost,toolbar_button,note_added,bulk_add'
            overwrite_destination = $false
        }
    )

    $others = @($Config.profiles | Where-Object {
        $_.note_type -ne $NoteType -and
        $_.name -notin @('ModernZ sentence furigana', 'ModernZ vocab furigana', 'ModernZ vocab pitch')
    })
    $Config.profiles = @($profiles + $others)
}

Write-Host "=== ModernZ mining card setup ==="
Write-Host "Deck: $DeckName"
Write-Host "Note type: $NoteType"
Write-Host ""

try {
    $null = Invoke-AnkiConnect -Body @{ action = 'version'; version = 6 }
} catch {
    Write-Host "ERROR: AnkiConnect is not reachable at $AnkiConnectUrl"
    Write-Host "Open Anki, make sure AnkiConnect is installed, then run this script again."
    exit 1
}

Invoke-AnkiConnect -Body @{
    action = 'createDeck'
    version = 6
    params = @{ deck = $DeckName }
} | Out-Null

$modelNames = @(Invoke-AnkiConnect -Body @{ action = 'modelNames'; version = 6 })
$modelExists = $modelNames -contains $NoteType

if (-not $modelExists) {
    Invoke-AnkiConnect -Body @{
        action = 'createModel'
        version = 6
        params = @{
            modelName = $NoteType
            inOrderFields = $Fields
            css = $CardCss
            cardTemplates = @(
                @{
                    Name = 'Recognition'
                    Front = $FrontTemplate
                    Back = $BackTemplate
                }
            )
        }
    } | Out-Null
    Write-Host "Created note type: $NoteType"
} else {
    $existingFields = @(Invoke-AnkiConnect -Body @{
        action = 'modelFieldNames'
        version = 6
        params = @{ modelName = $NoteType }
    })

    foreach ($field in $Fields) {
        if ($existingFields -notcontains $field) {
            Invoke-AnkiConnect -Body @{
                action = 'modelFieldAdd'
                version = 6
                params = @{
                    modelName = $NoteType
                    fieldName = $field
                }
            } | Out-Null
            Write-Host "Added field: $field"
        }
    }

    for ($i = 0; $i -lt $Fields.Count; $i++) {
        Invoke-AnkiConnect -Body @{
            action = 'modelFieldReposition'
            version = 6
            params = @{
                modelName = $NoteType
                fieldName = $Fields[$i]
                index = $i
            }
        } | Out-Null
    }

    $templates = Invoke-AnkiConnect -Body @{
        action = 'modelTemplates'
        version = 6
        params = @{ modelName = $NoteType }
    }

    if ($templates.Recognition) {
        Invoke-AnkiConnect -Body @{
            action = 'updateModelTemplates'
            version = 6
            params = @{
                model = @{
                    name = $NoteType
                    templates = @{
                        Recognition = @{
                            Front = $FrontTemplate
                            Back = $BackTemplate
                        }
                    }
                }
            }
        } | Out-Null
    } else {
        Invoke-AnkiConnect -Body @{
            action = 'modelTemplateAdd'
            version = 6
            params = @{
                modelName = $NoteType
                template = @{
                    Name = 'Recognition'
                    Front = $FrontTemplate
                    Back = $BackTemplate
                }
            }
        } | Out-Null
        Write-Host "Added Recognition template."
    }

    Invoke-AnkiConnect -Body @{
        action = 'updateModelStyling'
        version = 6
        params = @{
            model = @{
                name = $NoteType
                css = $CardCss
            }
        }
    } | Out-Null

    Write-Host "Updated note type: $NoteType"
}

$ajt = Find-AjtJapaneseConfig
if ($ajt) {
    $configCopy = $ajt.Config | ConvertTo-Json -Depth 50 | ConvertFrom-Json
    Set-AjtJapaneseProfiles -Config $configCopy
    ($configCopy | ConvertTo-Json -Depth 50) | Set-Content -Path $ajt.Path -Encoding UTF8
    Write-Host "Updated AJT Japanese profiles for $NoteType."
    Write-Host "Restart Anki if AJT Japanese was already loaded."
} else {
    Write-Host "WARN: AJT Japanese add-on config was not found."
    Write-Host "Install AJT Japanese with setup-anki-mining.ps1, then re-run this script for furigana/pitch."
}

Write-Host ""
Write-Host "Done. Use model '$NoteType' in mpvacious and Yomitan."
