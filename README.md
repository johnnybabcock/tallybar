# TallyBar

A macOS menu bar app that counts characters, words, and lines from your clipboard. Everything stays on-device — no network code, no analytics, no tracking.

Inspired by the original Bar Counter, which was removed from the Mac App Store.

## Features

- Live character / word / line count in the menu bar, updated whenever the clipboard changes
- Pick which metric to display: characters, characters (no spaces), words, lines
- Shorten label to a single letter (`123 c`) when menu bar space is tight
- Launch at Login (registered via `SMAppService`)
- App Sandbox + Privacy Manifest ready for Mac App Store

## Run from source

Requires macOS 13+, Swift 5.9+ (Xcode 15 or the Command Line Tools).

```sh
swift run
```

## Build a .app bundle

```sh
./Scripts/build-app.sh
open build/TallyBar.app
```

Optional env vars:

| Var | Default | What it does |
|---|---|---|
| `SIGN_IDENTITY` | `-` (ad-hoc) | Code-signing identity, e.g. `"Developer ID Application: Your Name (TEAMID)"` |
| `ENABLE_SANDBOX` | `0` | Apply the App Sandbox entitlement (required for App Store) |
| `UNIVERSAL` | `0` | Build a universal arm64 + x86_64 binary |

## Mac App Store submission

See [`App Store/SUBMISSION.md`](App%20Store/SUBMISSION.md) for the full checklist (bundle ID registration, App Store Connect setup, review notes, screenshots, upload).

## Privacy

[`docs/privacy.md`](docs/privacy.md) — the published version lives at <https://johnnybabcock.github.io/tallybar/privacy> once GitHub Pages is enabled.

## License

MIT.
