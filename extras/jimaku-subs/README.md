# Jimaku Subs

Fetch Japanese subtitles from [Jimaku](https://jimaku.cc/) inside mpv. Designed for **Seanime + debrid streams + ModernZ**.

## Features

- **Auto-fetch** on file open (uses `media-title` from Seanime debrid playback)
- **Manual reselect** with `Ctrl+Shift+J` if the wrong sub was picked
- **Stream cache** under `~/mpv_subs/` (Windows: `%USERPROFILE%\mpv_subs\`) for re-watching without re-downloading
- API key stored in local `script-opts/jimaku-subs.conf` only (never in this repo)

## Requirements

- mpv v0.38+ (for `mp.input`)
- `curl` on PATH
- Jimaku account + [API key](https://jimaku.cc/account)

## Install

1. Copy `jimaku-subs.js` to your mpv `scripts/` folder.

2. Copy `jimaku-subs.conf.example` to `script-opts/jimaku-subs.conf` and set your API key:

```
📁 mpv/portable_config/
├── 📁 script-opts/
│   └── 📄 jimaku-subs.conf    ← your key here, gitignored
└── 📁 scripts/
    └── 📄 jimaku-subs.js
```

3. Add to `input.conf` (optional; default binding is built into the script):

```ini
Ctrl+Shift+j    script-binding jimaku-subs/reselect
```

4. Recommended `mpv.conf` subtitle settings:

```ini
slang=ja,jp,jpn,en
sub-auto=fuzzy
sub-file-paths=~/mpv_subs:subs:subtitles
```

**Cache path note:** Use `~/mpv_subs` (user home) in `jimaku-subs.conf`, not `~~/mpv_subs`. With portable_config mpv, `~~` points at the config folder, not your home directory.

## Usage

| Action | Result |
|--------|--------|
| Open episode (Seanime → mpv) | Auto-searches Jimaku and loads best Japanese sub |
| `Ctrl+Shift+J` | Manual search / reselect subtitle file |

## Security

- Do **not** commit `jimaku-subs.conf` to git.
- Rotate your API key at [jimaku.cc/account](https://jimaku.cc/account) if it was ever exposed.

## Credits

Adapted from [ZXY101/mpv-jimaku](https://github.com/ZXY101/mpv-jimaku) (GPL-3.0).
