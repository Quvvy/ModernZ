# ModernZ Sentence Mining Setup

Sentence-first Anki mining for **Seanime -> mpv -> Jimaku -> ModernZ -> Anki** using [mpvacious](https://github.com/Ajatt-Tools/mpvacious). Yomitan is optional when you also want dictionary lookup or target-word fields.

This guide is the canonical setup path for ModernZ mining. It creates a dedicated deck and note type, so existing AJT `Japanese sentences` cards are not restyled.

## What this creates

- Deck: `Anime::Mining`
- Note type: `ModernZ Mining Sentence`
- Front: Japanese sentence only
- Back: Japanese sentence, English subtitle translation, anime screenshot, and anime audio clip
- Optional low-emphasis vocab fields for Yomitan-created notes

Missing translation, screenshot, audio, or vocab sections hide cleanly on the card instead of showing broken placeholders.

## Prerequisites

- Windows PowerShell and a working ModernZ/mpv config.
- [Anki](https://apps.ankiweb.net/) open while running setup and while mining.
- AnkiConnect add-on code `2055492159`. If http://127.0.0.1:8765 does not show JSON while Anki is open, install it from Anki: Tools -> Add-ons -> Get Add-ons.
- [mpvacious](https://github.com/Ajatt-Tools/mpvacious) installed into `portable_config/scripts/mpvacious/`.
- Japanese subtitles loaded in mpv. This workflow pairs well with [Jimaku-Subs](../jimaku-subs/).
- Optional English secondary subtitles for `SentEng`; `secondary_sub_visibility=auto` is fine because the track can be hidden while still being captured.

## Quick setup

1. Install Anki if needed:

```powershell
winget install Anki.Anki
```

2. Open Anki, install AnkiConnect add-on code `2055492159` if needed, then restart Anki.

3. Install or update mpvacious:

```powershell
$env:MPV_CONFIG_DIR = "$env:APPDATA\mpv\portable_config"
Set-Location "$env:APPDATA\mpv"
irm https://raw.githubusercontent.com/Ajatt-Tools/mpvacious/HEAD/scripts/install.ps1 | iex
```

4. Copy or merge the ModernZ mining examples into your mpv config:

- [`subs2srs.conf.example`](subs2srs.conf.example) -> `portable_config/script-opts/subs2srs.conf`
- [`input.conf.example`](input.conf.example) -> `portable_config/input.conf`

5. With Anki open, run the ModernZ setup script:

```powershell
powershell -ExecutionPolicy Bypass -File "$env:APPDATA\mpv\portable_config\setup-anki-mining.ps1"
```

This checks AnkiConnect, tries to install/update AJT Japanese add-on code `3918629684`, and runs `configure-mining-cards.ps1`.

6. Optional: enable the ModernZ OSC mining button in `modernz.conf`:

```ini
mining_button=yes
```

## Setup files

| File | Purpose |
|------|---------|
| `setup-anki-mining.ps1` | One-time helper that checks AnkiConnect, tries to install AJT Japanese, and runs the card setup. |
| `configure-mining-cards.ps1` | Canonical AnkiConnect setup for deck `Anime::Mining` and note type `ModernZ Mining Sentence`. |
| `configure-back-only-furigana.ps1` | Compatibility wrapper for older instructions; it calls `configure-mining-cards.ps1`. |
| `subs2srs.conf.example` | mpvacious settings for fields, media, secondary subtitles, and new-note media updates. |
| `input.conf.example` | Recommended mpvacious hotkeys, including direct card creation. |
| `YOMITAN-SETUP.md` | Optional browser dictionary setup for target-word fields. |
| `yomitan-anki-fields.example` | Field mapping reference for Yomitan. |
| `yomitan-settings-mining.json` | Optional Yomitan profile example. |

## Daily workflow

1. Open Anki and leave it running.
2. Play an episode in mpv with Japanese subtitles.
3. Optional: press `Ctrl+v` until the English secondary subtitle track is selected. Auto/hidden secondary subtitles still fill `SentEng`.
4. Pause on a sentence you want to keep.
5. Press `Ctrl+n`, or left-click the ModernZ mining button if enabled.
6. If you use the included `input.conf.example`, `g` is also mapped to the same direct new-card action.
7. The card appears in `Anime::Mining` with `SentKanji`, `SentEng`, `Image`, and `SentAudio`.

## Key bindings

| Key | Action |
|-----|--------|
| `Ctrl+n` | Create a new sentence card |
| `g` | Create a new sentence card when using the included input example |
| `a` | mpvacious menu |
| `Ctrl+v` | Toggle English secondary subtitles |
| `Ctrl+m` | Update last note with media |
| `Ctrl+c` | Copy Japanese subtitle |
| `Ctrl+t` | Toggle autocopy for Yomitan Search |
| `H` / `L` | Previous / next subtitle |
| `Alt+h` / `Alt+l` | Previous / next subtitle and pause |
| `Ctrl+Shift+J` | Jimaku manual subtitle search |

## ModernZ mining button

| Action | Result |
|--------|--------|
| Left click | Create a new sentence card |
| Right click | mpvacious menu |
| Middle click / Shift+left click | Copy current Japanese subtitle |
| Mouse wheel | Previous / next subtitle |

## Important config values

These should be present in `portable_config/script-opts/subs2srs.conf`:

```ini
deck_name=Anime::Mining
model_name=ModernZ Mining Sentence
sentence_field=SentKanji
secondary_field=SentEng
audio_field=SentAudio
image_field=Image
secondary_sub_auto_load=yes
secondary_sub_lang=eng,en
secondary_sub_visibility=auto
enable_new_note_timer=yes
```

## Troubleshooting

- **AnkiConnect errors**: open Anki and confirm http://127.0.0.1:8765 returns JSON. If not, install add-on code `2055492159` and restart Anki.
- **Wrong note type**: run `configure-mining-cards.ps1`, then confirm mpvacious and Yomitan use `ModernZ Mining Sentence`, not `Japanese sentences`.
- **No translation**: load or toggle an English secondary subtitle track with `Ctrl+v`. `secondary_sub_visibility=auto` may hide it visually, but it can still be captured.
- **No screenshot/audio**: press `Ctrl+m` to update the last note; confirm `enable_new_note_timer=yes` and that mpvacious can write to Anki's media folder.
- **Couldn't find the target note**: you opened mpvacious' quick-update flow, which expects a recent Yomitan-created note. Use `Ctrl+n`, `g` from the included input example, or the ModernZ mining button for a fresh sentence card.
- **Furigana missing**: run `setup-anki-mining.ps1`, then `configure-mining-cards.ps1`, and restart Anki.
- **Yomitan Search not updating**: confirm `autoclip=yes`; test by pasting the clipboard into Notepad.

## Optional Yomitan

Use [YOMITAN-SETUP.md](YOMITAN-SETUP.md) only when you want dictionary lookup or target-word fields. The main workflow remains mpvacious sentence-card creation from mpv.

## Credits

- [mpvacious](https://github.com/Ajatt-Tools/mpvacious) (GPL-3.0)
- [Yomitan](https://yomitan.wiki/)
- Works alongside [Jimaku subs](../jimaku-subs/) in this fork
