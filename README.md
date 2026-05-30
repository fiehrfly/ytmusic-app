# YouTube Music (macOS)

> **This is an unofficial YouTube Music Executable Chromium-based App.**
> It is not affiliated with, endorsed by, or sponsored by Google or YouTube. "YouTube
> Music" and the YouTube Music logo are trademarks of Google LLC, used here only to
> identify the service the app opens.

A self-contained macOS app that turns **YouTube Music** into its own lean, single-purpose
desktop application. It runs its **own branded Chromium engine**, so it appears as a
separate app — with the YouTube Music icon — in the Dock and the ⌘-Tab switcher, and is
**never grouped with Google Chrome**. It works whether or not you have Chrome installed.

**This is an unofficial YouTube Music Executable Chromium-based App** — a thin wrapper
around Chromium, not an official Google product.

## Features (what this app does)

- **Its own app identity** — runs under its own bundle identity (`com.marvincolcol.youtubemusic`),
  so macOS treats it as a distinct app: separate Dock icon, **separate ⌘-Tab entry**, never
  merged into a running Google Chrome. Easy to switch to and find.
- **Official YouTube Music icon** — the app and its window use the YouTube Music logo, so
  it's never confused with Chrome.
- **Works with or without Chrome** — it carries its own Chromium engine. On first launch it
  materializes that engine once into `~/Library/Application Support/YouTube Music/Engine`
  (reusing a Chromium already on your Mac if present, otherwise downloading the right build).
- **Intel + Apple Silicon** — the engine is fetched for your Mac's native architecture and
  runs native (no Rosetta). The same app works on both.
- **Locked to YouTube Music** — opens in a dedicated `--app` window with **no address bar
  and no tab strip**, so you can't type a URL or open in-window tabs. It stays on
  YouTube Music.
- **Lean & hardened** — no extensions, no themes, no sync, no usage pings, no background
  phone-home; a single renderer process for the one site (`--process-per-site`); disk cache
  capped (~100 MB); browser sandbox kept **on**; no automation.
- **No "Chrome for Testing" banner** — the testing-build notice is suppressed for a clean,
  app-like window.
- **Persistent, real sign-in** — your login is kept in a private profile across launches,
  and because it runs as a normal (non-automated) browser, **all Google sign-in methods
  work**, including passwords, passkeys, "use your phone", and security keys.
- **Tiny bundle** — the `.app` itself is ~180 KB (the engine lives in Application Support,
  set up once).
- **Single-instance** — relaunching (or clicking the Dock icon) focuses the existing window
  instead of opening a new one.
- **Media keys + Now Playing** — the keyboard media keys and the macOS Control Center /
  lock-screen "Now Playing" controls drive playback.
- **Self-updating engine** — a daily background check keeps the bundled Chromium current and
  swaps the update in on the next launch.
- **Slim on disk** — the engine is created with an APFS copy-on-write clone, so it shares
  storage with any Chromium already on your Mac instead of duplicating it.
- **Optional hard-lock (kiosk)** — run `touch "$HOME/Library/Application Support/YouTube Music/.kiosk"`
  to fully block Cmd+N / Cmd+T (this runs **fullscreen**); delete that file to return to the
  windowed app.

**Once more: this is an unofficial YouTube Music Executable Chromium-based App.**

## How it works

```
YouTube Music.app/                 (~180 KB launcher bundle)
└── Contents/
    ├── Info.plist                 # identity: com.marvincolcol.youtubemusic, "YouTube Music"
    ├── MacOS/launcher             # bash: materializes + launches the branded engine
    └── Resources/app.icns         # the YouTube Music logo

~/Library/Application Support/YouTube Music/
├── Engine/YouTube Music.app       # the branded Chromium engine (set up on first run)
└── profile/                       # your private login profile
```

On first run the launcher creates the engine: it takes a Chromium build (reused from a
local copy if available, else downloaded for your architecture), re-brands it as
"YouTube Music" with this app's identity + icon, ad-hoc signs it, and stores it in
Application Support. Every launch after that just opens that engine, locked to
`https://music.youtube.com/` with the lean/hardened flags above.

**Remember: this is an unofficial YouTube Music Executable Chromium-based App.**

## Install / build / package

```
cd ~/Tools/ytmusic-app
bash build.sh        # assembles the tiny "YouTube Music.app" launcher bundle
bash package.sh      # builds + zips dist/YouTube-Music-macOS.zip for sharing
cp -R "YouTube Music.app" /Applications/   # install
```

First launch sets up the engine (a one-time step; needs internet only if no local
Chromium is found). After that it opens instantly.

## Sending it to another Mac

Share `dist/YouTube-Music-macOS.zip`. On the new Mac:
1. First open: right-click the app → **Open** → **Open** (it's ad-hoc signed, so Gatekeeper
   asks once).
2. The first launch sets up the engine (downloads a Chromium build if the Mac has none).

## Troubleshooting

- Logs: `~/Library/Logs/YouTube Music.log`
- "Couldn't download the engine" → check your internet connection and reopen.
- Google asks to verify it's you → sign in once; it sticks in the private profile.

## Uninstall

```
rm -rf "/Applications/YouTube Music.app"
rm -rf "$HOME/Library/Application Support/YouTube Music"   # removes the engine + your login
```

---

**Disclaimer:** *This is an unofficial YouTube Music Executable Chromium-based App.* It is
not affiliated with or endorsed by Google or YouTube. All YouTube Music content, branding,
and trademarks belong to Google LLC. This project is a personal-use wrapper that simply
opens `music.youtube.com` in a dedicated Chromium window.
