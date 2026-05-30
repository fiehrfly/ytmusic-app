# YouTube Music (macOS app)

A real, double-clickable macOS app that opens **YouTube Music** in its own clean
window — no browser tabs, no address bar. It launches your real **Google Chrome**
directly (no automation), so every Google sign-in method works — including passkeys,
"use your phone", and security keys — and keeps you signed in across launches.
**Playwright** stays bundled as a fallback engine for Macs without Chrome.

## What you get

- `YouTube Music.app` — a standard macOS `.app` bundle. Put it in `/Applications`,
  launch it from Spotlight / Launchpad / Dock like any other app.
- **First launch asks you to sign in** to your Google / YouTube Music account, in a
  private profile that belongs only to this app. After that, it stays logged in.
- A **fully-open, dedicated window** (`--app` mode) showing music.youtube.com.

## How it works

```
YouTube Music.app/
└── Contents/
    ├── Info.plist
    ├── MacOS/launcher        # bash: launches your Chrome directly (Playwright fallback)
    └── Resources/
        ├── app.icns
        └── app/
            ├── ytmusic.js    # Playwright fallback engine (only if no system Chrome)
            ├── package.json
            └── node_modules/ # bundled Playwright (pure JS)
```

- **Browser engine:** if **Google Chrome** (or Edge) is installed, the app launches it
  **directly** in `--app` mode — a normal, non-automated Chrome process pinned to your
  Mac's native architecture. That matters: driving Chrome through automation (CDP +
  mock keychain) is exactly what makes Google block passkeys and other non-password
  sign-in. A direct launch gives you real codecs + Widevine DRM, the OS keychain
  (where passkeys live), and a browser Google trusts. If no Chrome/Edge is found, it
  falls back to Playwright's bundled Chromium (downloaded on first run; note plain
  Chromium lacks the AAC codec + Widevine, so audio may not play — install Chrome).
- **Login persistence:** a dedicated profile at
  `~/Library/Application Support/YouTube Music/profile`.

## Intel + Apple Silicon

The app ships **no architecture-locked binaries** — the launcher is a shell script
and the payload is pure-JS Playwright. The actual browser is acquired at runtime for
the host architecture (system Chrome is universal; bundled Chromium downloads the
correct Intel/ARM build). So the same `.app` runs on both Intel and Apple Silicon
Macs. Requirement on any Mac: **Node.js** must be installed (the app shows a prompt
with install instructions if it isn't).

## Build / rebuild

```bash
cd ~/Tools/ytmusic-app
bash build.sh                      # produces "YouTube Music.app" here
cp -R "YouTube Music.app" /Applications/   # install
```

## Sending it to another Mac

Zip `YouTube Music.app` and copy it over. On the new Mac:
1. Make sure **Node.js** is installed (https://nodejs.org).
2. The first open may show "unidentified developer" (it's unsigned) — right-click the
   app → **Open** → **Open**, once.
3. First launch bootstraps its browser engine, then asks you to sign in.

## Troubleshooting

- Logs: `~/Library/Logs/YouTube Music.log`
- "Needs Node.js" dialog → install Node LTS, reopen.
- Google says the browser isn't secure → make sure Chrome is installed (the app
  prefers real Chrome, which Google trusts); sign in once and it sticks.

## Uninstall

```bash
rm -rf "/Applications/YouTube Music.app"
rm -rf "$HOME/Library/Application Support/YouTube Music"   # also forgets your login
```
