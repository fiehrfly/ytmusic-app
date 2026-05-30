# YouTube Music (macOS)

A **simple Chromium wrapper** that turns **YouTube Music** into a lean, single-purpose,
double-clickable macOS app. It opens `music.youtube.com` in a dedicated, locked window —
no address bar, no tabs, no extensions, no themes — and keeps you signed in across
launches. It works with every Google sign-in method (passwords, **passkeys**, "use your
phone", security keys), because it runs as a normal, non-automated browser.

## What you get

- `YouTube Music.app` — a standard macOS `.app`. Put it in `/Applications` and launch it
  from Spotlight / Launchpad / Dock.
- **First launch asks you to sign in** to your Google / YouTube Music account, in a
  private profile that belongs only to this app. After that, it stays logged in.
- A **dedicated, locked window**: no URL bar and no tab strip, so it can't be turned into
  a general-purpose browser.

## Works with or without Chrome

The app picks the best engine available, automatically:

- **You have Chrome / Edge / Brave (preferred):** it launches that browser **directly** —
  real codecs (AAC) + Widevine DRM for full playback, and a browser Google trusts for
  sign-in. Pinned to your Mac's **native architecture** (no Rosetta on Apple Silicon).
  This path needs no Node and downloads nothing.
- **No Chromium browser installed (fallback):** it runs a **bundled Chromium** engine
  (via Playwright). On first run it downloads the correct build for your Mac's
  architecture, then opens the same locked window. (Plain Chromium lacks Widevine, so
  some DRM-protected content may not play — installing Google Chrome is recommended.)

So the app **always runs**, on any Mac.

## Lean & hardened by design

It drives the browser with flags that keep it slim and locked down. Sandbox stays **ON**;
no automation.

- **Locked to YouTube Music** — `--app` mode removes the address bar and tab strip, so you
  can't type a URL or open an in-window tab.
- **No extensions / no themes** — `--disable-extensions`; the private profile starts clean
  and stays that way (smaller attack surface, less RAM).
- **Lean on RAM** — one renderer process for the single site (`--process-per-site`),
  background networking and sync turned off.
- **Lean on storage** — disk cache capped (~100 MB); the launcher bundle itself is tiny.
- **Private** — no sync, no usage pings, no background phone-home.

### New tabs / new windows

- **Fallback (bundled Chromium) path:** new tabs and new windows are **fully blocked** —
  any that open are closed instantly, `window.open` is neutralized, and Cmd/Ctrl+T and
  Cmd/Ctrl+N are trapped. The window stays locked to YouTube Music.
- **Direct-Chrome path:** the address bar and tab strip are gone (you can't type a URL or
  open an in-window tab). One honest limitation: in a normal **windowed** Chrome, there is
  **no command-line flag** to block a deliberate **Cmd+N** — only a browser extension
  (intentionally omitted) or **kiosk/fullscreen** mode can. If you want that block on the
  Chrome path too, the app can be switched to kiosk (fullscreen) mode — ask and it's a
  one-line change.

## How it works

```
YouTube Music.app/
└── Contents/
    ├── Info.plist
    ├── MacOS/launcher        # bash: finds your Chrome, launches it locked + lean (native arch)
    └── Resources/
        ├── app.icns
        └── app/
            ├── ytmusic.js    # bundled-Chromium fallback engine (locks tabs/windows)
            ├── package.json
            └── node_modules/ # bundled Playwright (pure JS; ~17 MB)
```

- **Login persistence:** a dedicated profile at
  `~/Library/Application Support/YouTube Music/profile`.

## Intel + Apple Silicon

Universal: the launcher is a shell script that runs your browser at the Mac's native
architecture, and the bundled fallback is pure-JS Playwright (the actual Chromium is
fetched per-architecture at runtime). The same `.app` works on both Intel and Apple
Silicon.

## Build / package

```
cd ~/Tools/ytmusic-app
bash build.sh        # assembles "YouTube Music.app"
bash package.sh      # builds + zips dist/YouTube-Music-macOS.zip for sharing
cp -R "YouTube Music.app" /Applications/   # install
```

## Sending it to another Mac

Share `dist/YouTube-Music-macOS.zip`. On the new Mac:
1. (Recommended) install **Google Chrome** for full playback — otherwise the bundled
   engine downloads on first run.
2. First open: right-click the app → **Open** → **Open** (it's ad-hoc signed, so
   Gatekeeper asks once).

## Troubleshooting

- Logs: `~/Library/Logs/YouTube Music.log`
- Google says the browser isn't secure → make sure Chrome is installed (the app prefers
  real Chrome, which Google trusts); sign in once and it sticks.

## Uninstall

```
rm -rf "/Applications/YouTube Music.app"
rm -rf "$HOME/Library/Application Support/YouTube Music"   # also forgets your login
```
