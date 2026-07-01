# ModernZ Sentence Mining

Sentence-first Anki mining for **Seanime -> mpv -> Jimaku -> ModernZ -> Anki** using [mpvacious](https://github.com/Ajatt-Tools/mpvacious). Yomitan is optional when you also want dictionary lookup or a target word.

## What gets installed

| Component | Location |
|-----------|----------|
| mpvacious scripts | `portable_config/scripts/mpvacious/` |
| Mining config | `portable_config/script-opts/subs2srs.conf` |
| Hotkeys | `portable_config/input.conf` |
| Anki add-on setup | `portable_config/setup-anki-mining.ps1` |
| ModernZ card setup | `portable_config/configure-mining-cards.ps1` |

## One-time setup

### 1. Anki

Install Anki from [ankiweb.net](https://apps.ankiweb.net/) or with:

```powershell
winget install Anki.Anki
```

AnkiConnect must be installed first. If http://127.0.0.1:8765 does not show JSON while Anki is open, install it in Anki:

1. Tools -> Add-ons -> Get Add-ons...
2. Code: `2055492159`
3. Restart Anki

Then run the setup script:

```powershell
powershell -ExecutionPolicy Bypass -File "$env:APPDATA\mpv\portable_config\setup-anki-mining.ps1"
```

This checks AnkiConnect, tries to install/update AJT Japanese, then runs the ModernZ card setup.

If AJT Japanese cannot be installed automatically, install it in Anki with add-on code `3918629684`, restart Anki, and rerun the script.

Open Anki and verify AnkiConnect at http://127.0.0.1:8765.

### 2. ModernZ mining cards

With Anki open, run:

```powershell
powershell -ExecutionPolicy Bypass -File "$env:APPDATA\mpv\portable_config\configure-mining-cards.ps1"
```

This creates or updates:

- Deck: `Anime::Mining`
- Note type: `ModernZ Mining Sentence`
- Card front: Japanese sentence only
- Card back: Japanese sentence, English subtitle translation, anime screenshot, and sentence audio

The old `configure-back-only-furigana.ps1` name still works as a wrapper, but new setup should use `configure-mining-cards.ps1`.

### 3. mpvacious

```powershell
$env:MPV_CONFIG_DIR = "$env:APPDATA\mpv\portable_config"
Set-Location "$env:APPDATA\mpv"
irm https://raw.githubusercontent.com/Ajatt-Tools/mpvacious/HEAD/scripts/install.ps1 | iex
```

If the installer overwrites settings, re-apply [`subs2srs.conf.example`](subs2srs.conf.example).

### 4. Optional Yomitan

Follow [YOMITAN-SETUP.md](YOMITAN-SETUP.md) if you want dictionary lookup and optional target-word fields. The card still stays sentence-first.

### 5. Optional ModernZ mining button

Enable the OSC mining button in `modernz.conf`:

```ini
mining_button=yes
```

The button reuses the subtitle icon and shows the tooltip `Mine sentence`.

## Mining workflow

1. Open Anki and leave it running.
2. Play an episode in Seanime; Jimaku loads Japanese subtitles in mpv.
3. Optional: press `Ctrl+v` to enable an English secondary subtitle track.
4. Pause on a sentence you want to keep.
5. Press `Ctrl+n`, or click the ModernZ mining button if enabled. If you use the included `input.conf.example`, `g` is also mapped to this direct new-card action.
6. mpvacious creates a card in `Anime::Mining` and attaches:
   - `SentKanji`: Japanese sentence
   - `SentEng`: English subtitle line when available
   - `Image`: screenshot from the scene
   - `SentAudio`: audio clip from the sentence

## Card result

**Front:** Japanese sentence only, no furigana.

**Back:** Japanese sentence, English translation, anime screenshot, and sentence audio. Optional furigana, target-word details, and notes appear only when those fields are present.

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

## Config

See [`subs2srs.conf.example`](subs2srs.conf.example). Important values:

- `deck_name=Anime::Mining`
- `model_name=ModernZ Mining Sentence`
- `sentence_field=SentKanji`
- `secondary_field=SentEng`
- `audio_field=SentAudio`
- `image_field=Image`
- `enable_new_note_timer=yes`
- `secondary_sub_lang=eng,en`
- `audio_padding=0.3`

## Troubleshooting

- **AnkiConnect errors**: Anki must be open; check http://127.0.0.1:8765.
- **Wrong note type**: Run `configure-mining-cards.ps1`, then set mpvacious/Yomitan to `ModernZ Mining Sentence`.
- **No translation**: load or toggle an English secondary subtitle track with `Ctrl+v`.
- **No screenshot/audio**: press `Ctrl+m` to update the last note; confirm `enable_new_note_timer=yes`.
- **Couldn't find the target note**: you opened mpvacious' quick-update flow, which expects a recent Yomitan-created note. Use `Ctrl+n` or the ModernZ mining button for a fresh sentence card.
- **Yomitan Search not updating**: confirm `autoclip=yes`; test by pasting the clipboard into Notepad.
- **Furigana missing**: run `setup-anki-mining.ps1`, then `configure-mining-cards.ps1`, and restart Anki.

## Credits

- [mpvacious](https://github.com/Ajatt-Tools/mpvacious) (GPL-3.0)
- [Yomitan](https://yomitan.wiki/)
- Works alongside [Jimaku subs](../jimaku-subs/) in this fork
