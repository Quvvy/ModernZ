# Yomitan setup for ModernZ sentence mining

Yomitan is optional in the ModernZ sentence-first workflow. Use it when you want dictionary lookup or target-word fields on the back of the card. Sentence, translation, screenshot, and audio still come from mpvacious.

## Prerequisites

- Anki is installed and running.
- `setup-anki-mining.ps1` has installed AnkiConnect and AJT Japanese.
- `configure-mining-cards.ps1` has created `ModernZ Mining Sentence`.
- mpvacious uses `model_name=ModernZ Mining Sentence` in [`subs2srs.conf.example`](subs2srs.conf.example).

## 1. Install Yomitan

Install the official extension only.

| Browser | Install |
|---------|---------|
| Chrome / Edge | [Chrome Web Store - Yomitan](https://chromewebstore.google.com/detail/yomitan/likgcciljapiegoolpeipdmnemglfblo) |
| Firefox | [Firefox Add-ons - Yomitan](https://addons.mozilla.org/firefox/addon/yomitan/) |

## 2. Install dictionaries

Download `.zip` dictionary files and import them without unzipping:

- Required: [JMdict](https://github.com/MarvNC/JP-Dictionaries/releases)
- Optional: KANJIDIC and Kanjium

In Yomitan: **Settings -> Dictionaries -> Configure installed and enabled dictionaries -> Import**.

## 3. Configure Anki integration

1. Open Yomitan settings.
2. Enable **Advanced**.
3. In **Anki**:
   - Enable Anki integration: ON
   - Server: `http://127.0.0.1:8765`
   - Check for card duplicates: OFF
4. Open **Configure Anki card format...**.
5. Select the **Terms** tab.
6. Set deck/model:
   - Deck: `Anime::Mining`
   - Model: `ModernZ Mining Sentence`
7. Fill fields from [yomitan-anki-fields.example](yomitan-anki-fields.example).

| Anki field | Yomitan marker |
|------------|----------------|
| `VocabKanji` | `{expression}` |
| `VocabDef` | `{glossary-brief}` |
| `SentKanji` | `{cloze-prefix}{cloze-body}{cloze-suffix}` |
| `VocabPitchPattern` | `{pitch-accents}` |
| `VocabPitchNum` | `{pitch-accent-positions}` |
| All other fields | leave empty |

Leave `SentEng`, `SentAudio`, and `Image` empty in Yomitan; mpvacious fills them from the current subtitle, scene, and audio.

## 4. Clipboard monitoring

Go to **Settings -> Clipboard**:

- Enable search page clipboard monitoring: ON
- Auto-search content: ON

With `autoclip=yes`, mpvacious copies the current Japanese subtitle to the clipboard so the pinned Yomitan Search tab updates as you watch.

## 5. Recommended toggles

| Setting | Location | Value |
|---------|----------|-------|
| Auto-play search result audio | Audio | OFF |
| Enable audio playback for terms | Audio | OFF |
| Scan delay | Scanning | `0` |

Use mpv sentence audio on cards, not Yomitan audio.

## Mining with Yomitan

1. Open Anki.
2. Open the pinned Yomitan Search tab.
3. Play anime in Seanime/mpv with Japanese subtitles.
4. Optional: press `Ctrl+v` in mpv for English secondary subtitles.
5. In Yomitan Search, Shift+hover a target word and click `+`.
6. mpvacious attaches `SentEng`, `Image`, and `SentAudio` shortly after the note is created.

The resulting card remains sentence-first: front sentence only; back sentence, translation, screenshot, audio, and optional word details.

## Optional settings reference

See [yomitan-settings-mining.json](yomitan-settings-mining.json) for values to copy. It is a reference fragment, not a full Yomitan backup export.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `+` button grayed out | Open Anki and confirm AnkiConnect at http://127.0.0.1:8765. |
| Wrong model | Set Yomitan Terms model to `ModernZ Mining Sentence`. |
| No media | Create the note while mpv is open on the sentence; press `Ctrl+m` to update the last note. |
| No English translation | Load/toggle an English secondary subtitle track with `Ctrl+v`. |
| Yomitan Search empty | Confirm `autoclip=yes` and paste clipboard into Notepad to test. |
| Furigana missing | Run `configure-mining-cards.ps1` and restart Anki. |

## Further reading

- [Yomitan Anki integration docs](https://yomitan.wiki/anki/)
- [AJT Yomitan setup](https://tatsumoto.neocities.org/blog/setting-up-yomichan.html)
- [mpv-mining README](README.md)
