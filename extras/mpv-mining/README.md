# mpv + Anki Sentence Mining

Sentence mining for **Seanime → mpv → Jimaku Japanese subs → Anki** using [mpvacious](https://github.com/Ajatt-Tools/mpvacious).

## What gets installed (local mpv config)

| Component | Location |
|-----------|----------|
| mpvacious scripts | `portable_config/scripts/mpvacious/` |
| Mining config | `portable_config/script-opts/subs2srs.conf` |
| Hotkeys | `portable_config/input.conf` |
| Anki one-time setup | `portable_config/setup-anki-mining.ps1` |

## One-time Anki setup

1. **Anki** must be installed ([ankiweb.net](https://apps.ankiweb.net/) or `winget install Anki.Anki`).

2. Run the setup script:

```powershell
powershell -ExecutionPolicy Bypass -File "$env:APPDATA\mpv\portable_config\setup-anki-mining.ps1"
```

This installs:
- **AnkiConnect** (code `2055492159`) — lets mpv talk to Anki
- **AJT Japanese sentences** note type (code `1557722832`) — mining card template

3. Open **Anki** and leave it running while you mine.

4. Test AnkiConnect: open http://127.0.0.1:8765 in a browser — you should see JSON with a version number.

## Install / update mpvacious

```powershell
$env:MPV_CONFIG_DIR = "$env:APPDATA\mpv\portable_config"
Set-Location "$env:APPDATA\mpv"
irm https://raw.githubusercontent.com/Ajatt-Tools/mpvacious/HEAD/scripts/install.ps1 | iex
```

Then re-apply custom `subs2srs.conf` settings from [`subs2srs.conf.example`](subs2srs.conf.example) if the installer overwrote them.

## Mining workflow

1. Play an episode from **Seanime** (Jimaku loads Japanese subs automatically).
2. Pause on an interesting line.
3. Press **`g`** for a quick card from the current subtitle, or **`a`** for the full mpvacious menu.
4. Card goes to deck **`Anime::Mining`** with sentence, optional English secondary sub, audio clip, and screenshot.

## Key bindings

| Key | Action |
|-----|--------|
| `a` | mpvacious main menu |
| `g` | Quick card from current subtitle |
| `Ctrl+n` | Export note to Anki |
| `H` / `L` | Previous / next subtitle line |
| `Alt+h` / `Alt+l` | Previous / next line (pause) |
| `Ctrl+c` | Copy Japanese sub to clipboard |
| `Ctrl+v` | Toggle secondary (English) subs |
| `Ctrl+Shift+J` | Jimaku manual sub search (separate script) |

## Config

See [`subs2srs.conf.example`](subs2srs.conf.example). Main settings:

- `deck_name=Anime::Mining`
- `model_name=Japanese sentences`
- `create_deck=yes`

## Troubleshooting

- **AnkiConnect errors**: Anki must be open; check http://127.0.0.1:8765
- **No audio/image on cards**: For debrid streams keep `use_ffmpeg=no` in subs2srs.conf; for local files try `use_ffmpeg=yes` if ffmpeg is on PATH (`%APPDATA%\mpv\ffmpeg.exe`)
- **Wrong note type**: Run `setup-anki-mining.ps1` or match `model_name` / field names in subs2srs.conf to your Anki note type

## Credits

- [mpvacious](https://github.com/Ajatt-Tools/mpvacious) (GPL-3.0)
- Works alongside [Jimaku subs](../jimaku-subs/) in this fork
