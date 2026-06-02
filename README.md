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

## ⚠️ Disclaimer

**Unofficial. Not affiliated with, endorsed by, or sponsored by Google or YouTube.** "Google",
"YouTube", and "YouTube Music" — and the YouTube Music name and logo — are trademarks of Google
LLC, used here **for identification only** to indicate the service this app opens; the author
claims no ownership of them. This is a free, **non-commercial** personal project, provided
**"as is"** with no warranty. It contains **no Google code** (the Chromium engine is downloaded at
runtime, never redistributed here) and does not host or redistribute any YouTube content.

**Full details → [DISCLAIMER.md](DISCLAIMER.md) · [Third-party notices](THIRD-PARTY-NOTICES.md) · [License](LICENSE).**

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

## Install — the easy, step-by-step way

> Don't worry if you've never used a "Terminal" or GitHub before. There are **two ways** to
> install, and the first one is the simplest thing on a Mac: **download one file, then drag
> it onto your Applications folder.** No typing, no Terminal. 🙂
>
> - **Option A — Download & drag (recommended for everyone).** Just download a file and
>   drag. Pick this one.
> - **Option B — Build it yourself** (only if you'd rather get the source code from GitHub).

### Before you start — what you need (prerequisites)

- ✅ **A Mac** (an Apple computer) running **macOS**. It works on both kinds of Mac —
  older Intel Macs and newer Apple Silicon (M1 / M2 / M3 / M4). You don't need to know
  which one you have.
- ✅ **An internet connection** (Wi-Fi or cable). You need it the **first time** you open
  the app, and to download the files.
- ✅ **About 5 minutes.**
- ✅ That's all. You do **not** need to be a coder, and you do **not** need to install
  anything extra — everything the app needs is already built into your Mac.

---

## Option A — Download & drag (recommended) 🎯

This is the easy way. You download **one file**, open it, and drag the app into your
Applications folder — exactly like installing most Mac apps.

1. Go to the **Releases** page:
   👉 **https://github.com/fiehrfly/ytmusic-app/releases/latest**
2. Under **Assets**, click **`YouTube-Music-macOS.dmg`** to download it. It saves to your
   **Downloads** folder.
3. In **Downloads**, **double-click `YouTube-Music-macOS.dmg`**. A window opens showing the
   **YouTube Music** icon and a shortcut to your **Applications** folder, with an arrow
   between them.
4. **Drag the YouTube Music icon onto the Applications folder** (follow the arrow). That
   copies the app onto your Mac. ✅
5. You can now close that window and **eject** the disk image: in Finder's sidebar, click
   the little ⏏ next to **"YouTube Music."**

**Now open it the first time:**

6. Open your **Applications** folder (in Finder's top menu: **`Go` → `Applications`**), find
   **`YouTube Music`**, **right-click it** (or hold **`Control`** and click), then choose
   **`Open`**.
7. A box may warn that the app is from an "unidentified developer." That's normal for a free
   app that isn't from the App Store. Click **`Open`**. **You only do this the very first time.**
8. The first launch takes about **30–60 seconds** while it sets itself up (it needs the
   internet this once). After that, it opens instantly. **Sign in once** and it remembers you.

**That's it — you're done! 🎵** Keep it in your Dock and click it like any other app.

> **Why the one-time right-click?** This is a free app that isn't signed with a paid Apple
> developer certificate, so macOS double-checks with you the first time. Right-click → Open
> tells macOS you trust it. It only ever happens once.

---

## Option B — Build it yourself from the source code

Prefer to get the actual source code from GitHub and make the app on your own machine? This
takes a few more steps but still requires **no coding** — you copy and paste **two short
lines**.

### Step 1 — Get the files from GitHub

The app's files live on a free website called **GitHub**, here:
👉 **https://github.com/fiehrfly/ytmusic-app**

1. Open that link in your web browser (Safari or Chrome — either is fine).
2. Look for the big **green button** near the top that says **`< > Code`**. **Click it.**
3. A small menu drops down. At the **bottom** of that menu, click **Download ZIP**.
4. A file named **`ytmusic-app-main.zip`** will save to your **Downloads** folder.
5. Open your **Downloads** folder and **double-click that ZIP file**. It will turn into a
   **folder** named **`ytmusic-app-main`**. (Double-clicking a ZIP just unpacks it.)

> 💡 **Tip:** Keep that `ytmusic-app-main` folder somewhere easy, like your **Desktop**.
> You can drag it there now.

### Step 2 — Build the app (copy & paste two lines)

"Building" just means turning the files into a real clickable app. Your Mac does the work —
you only press a couple of keys.

1. **Open the Terminal app.** Press the **`Command (⌘)`** key and the **`Spacebar`** at the
   same time. A search box appears. Type the word **`Terminal`** and press **`Return`**
   (the Enter key). A plain window with text opens — that's Terminal. It's safe.
2. In the Terminal window, type **`cd`** and then **one space**. (`cd` means "go to a
   folder.") **Do not press Return yet.**
3. Now **drag the `ytmusic-app-main` folder** from your Desktop **into the Terminal
   window** and let go. The folder's location gets typed in for you automatically. ✨
   Now press **`Return`**.
4. Type (or copy-paste) this exact line and press **`Return`**:

   ```
   bash build.sh
   ```

   Wait a few seconds. When you see the word **`Done:`**, the app has been built. 🎉

### Step 3 — Put the app with your other apps

1. Go back to your **`ytmusic-app-main` folder** (on the Desktop). You'll now see a new
   item there called **`YouTube Music`** with the red-and-white YouTube Music icon. **That's
   your app.**
2. Open your **Applications** folder: in any Finder window, click the **`Go`** menu at the
   top of the screen, then click **`Applications`**.
3. **Drag** the **`YouTube Music`** app into the **Applications** folder. (This is the same
   as "installing" it.)

### Step 4 — Open it for the first time

1. In **Applications**, find **`YouTube Music`**. **Don't double-click yet** — instead,
   **right-click** it (or hold the **`Control`** key and click), then choose **`Open`**.
2. A box may pop up warning that the app is from an "unidentified developer." This is
   normal for free apps that don't come from the App Store. Click **`Open`** in that box.
   **You only have to do this the very first time.**
3. The **first launch takes about 30–60 seconds** while it sets itself up (this is when it
   needs the internet). After that, it opens instantly every time.
4. When YouTube Music appears, **sign in once**. The app remembers you, so you won't have
   to sign in again.

**Done! 🎵** From now on, just click **YouTube Music** in your Applications (or keep it in
your Dock) like any other app.

---

### Give the app to a friend (optional)

Want to share the finished app so a friend **doesn't** have to do any of the steps above?
Make the same drag-to-install disk image (.dmg) that the Releases page uses:

1. In Terminal (still in the same folder from Step 2), run:

   ```
   bash make-dmg.sh
   ```

2. This creates **one file**: **`dist/YouTube-Music-macOS.dmg`**.
3. Send that file to your friend (AirDrop, email, or a USB stick).
4. On **their** Mac, they only need to: **double-click the .dmg → drag `YouTube Music` onto
   Applications → right-click → Open → Open.** No GitHub and no Terminal needed for them. The
   first launch sets up the engine (it needs internet once).

> Prefer a plain zip instead of a disk image? `bash package.sh` makes
> `dist/YouTube-Music-macOS.zip` — they unzip it, then drag the app into Applications.

---

### Quick version (for people comfortable with the Terminal)

```
git clone https://github.com/fiehrfly/ytmusic-app.git
cd ytmusic-app
bash build.sh                              # builds "YouTube Music.app"
cp -R "YouTube Music.app" /Applications/   # install
# bash make-dmg.sh                         # optional: drag-to-Applications .dmg (for Releases)
# bash package.sh                          # optional: plain .zip for sharing
```

First launch sets up the branded Chromium engine once (needs internet only if no local
Chromium is found). After that it opens instantly.

## Troubleshooting

- Logs: `~/Library/Logs/YouTube Music.log`
- "Couldn't download the engine" → check your internet connection and reopen.
- Google asks to verify it's you → sign in once; it sticks in the private profile.

## Uninstall

```
rm -rf "/Applications/YouTube Music.app"
rm -rf "$HOME/Library/Application Support/YouTube Music"   # removes the engine + your login
```

## License & trademarks

- This project's **own source code** (`launcher`, `build.sh`, `package.sh`, docs) is released
  under the **[MIT License](LICENSE)**.
- The **"YouTube Music" name and logo** (`icon.svg`, `app.icns`) are **trademarks of Google LLC** —
  not covered by the MIT license and not claimed by the author; included only as the app's icon for
  identification. See **[DISCLAIMER.md](DISCLAIMER.md)**.
- The **browser engine** (Chromium / Google Chrome for Testing) is third-party software, downloaded
  at runtime and never redistributed here. See **[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md)**.

---

**Disclaimer:** *This is an unofficial YouTube Music Executable Chromium-based App.* It is
not affiliated with or endorsed by Google or YouTube. All YouTube Music content, branding,
and trademarks belong to Google LLC. This project is a personal-use wrapper that simply
opens `music.youtube.com` in a dedicated Chromium window.
