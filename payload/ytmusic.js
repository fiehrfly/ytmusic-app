// YouTube Music — bundled-engine fallback.
//
// Used ONLY when no system Chrome/Edge/Brave/Chromium is installed. It drives
// Playwright's bundled Chromium in a locked, single-purpose window:
//   • no new tabs and no new windows (any that appear are closed immediately),
//   • window.open() is neutralized and Cmd/Ctrl+T / Cmd/Ctrl+N are trapped,
//   • the window stays on the YouTube Music URL (off-site nav is bounced home),
//     while still allowing the Google sign-in domains so login works.
//
// The app's PRIMARY path launches your real Chrome directly (better: proprietary
// codecs + Widevine DRM + trusted Google sign-in). This fallback exists so the app
// still runs on a Mac with no Chromium browser at all. On first run with no system
// browser, Playwright downloads the correct Chromium build for this Mac's architecture.
const { chromium } = require('playwright');
const path = require('path');
const os = require('os');
const fs = require('fs');

const TARGET = 'https://music.youtube.com/';
// Hosts the locked window is allowed to show: YouTube Music itself + the Google
// sign-in surfaces it needs (passkeys / account flows). Everything else is bounced home.
const ALLOW = /^(https?:\/\/)?([^/]*\.)?(music\.youtube\.com|accounts\.google\.com|accounts\.youtube\.com|myaccount\.google\.com|gstatic\.com)(\/|$|\?)/i;

const SUPPORT = path.join(os.homedir(), 'Library', 'Application Support', 'YouTube Music');
const userDataDir = path.join(SUPPORT, 'profile');
fs.mkdirSync(userDataDir, { recursive: true });

// Lean + hardened args (mirror the direct-Chrome path). No automation banner; allow the
// real keychain so passkeys aren't blocked by Playwright's default mock keychain.
const args = [
  '--app=' + TARGET,
  '--no-first-run',
  '--no-default-browser-check',
  '--disable-sync',
  '--disable-background-networking',
  '--disable-default-apps',
  '--no-pings',
  '--process-per-site',
  '--disk-cache-size=104857600',
  '--disable-features=Translate',
];

function log(msg) {
  try {
    const dir = path.join(os.homedir(), 'Library', 'Logs');
    fs.mkdirSync(dir, { recursive: true });
    fs.appendFileSync(path.join(dir, 'YouTube Music.log'),
      `[${new Date().toISOString()}] ${msg}\n`);
  } catch (_) {}
}

(async () => {
  const context = await chromium.launchPersistentContext(userDataDir, {
    headless: false,
    viewport: null,
    ignoreDefaultArgs: ['--enable-automation', '--use-mock-keychain'],
    args,
  });

  // Lock #1: neutralize window.open and trap new-tab/new-window keyboard shortcuts on
  // every page/frame (runs before page scripts).
  await context.addInitScript(() => {
    try { window.open = () => null; } catch (e) {}
    window.addEventListener('keydown', (e) => {
      const k = (e.key || '').toLowerCase();
      if ((e.metaKey || e.ctrlKey) && (k === 't' || k === 'n')) {
        e.preventDefault();
        e.stopPropagation();
      }
    }, true);
  }).catch(() => {});

  let page = context.pages()[0] || await context.waitForEvent('page', { timeout: 20000 });

  // Lock #2: close any extra tab/window the moment it opens — UNLESS it's a Google
  // sign-in surface (those must survive for login). New blank tabs / off-site windows
  // are closed.
  context.on('page', async (p) => {
    if (p === page) return;
    await p.waitForLoadState('domcontentloaded', { timeout: 3000 }).catch(() => {});
    if (!ALLOW.test(p.url())) {
      await p.close().catch(() => {});
    }
  });

  // Lock #3: keep the main frame on YouTube Music / Google sign-in. Any other top-level
  // navigation is bounced back to YouTube Music.
  page.on('framenavigated', async (frame) => {
    if (frame !== page.mainFrame()) return;
    const u = frame.url();
    if (u && u !== 'about:blank' && !ALLOW.test(u)) {
      await page.goto(TARGET, { waitUntil: 'domcontentloaded' }).catch(() => {});
    }
  });

  if (!/music\.youtube\.com/.test(page.url())) {
    await page.goto(TARGET, { waitUntil: 'domcontentloaded' }).catch(() => {});
  }
  log('fallback ready (locked bundled Chromium)');

  // Stay alive until the window is closed / the app is quit.
  await new Promise((resolve) => {
    let done = false;
    const finish = () => { if (!done) { done = true; resolve(); } };
    context.on('close', finish);
    const iv = setInterval(() => {
      if (context.pages().length === 0) { clearInterval(iv); finish(); }
    }, 1000);
  });

  await context.close().catch(() => {});
  process.exit(0);
})().catch((err) => {
  log(`ERROR ${err && err.stack ? err.stack : err}`);
  process.exit(1);
});
