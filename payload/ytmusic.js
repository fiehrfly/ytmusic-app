// YouTube Music — Playwright FALLBACK engine (used only when no system Chrome/Edge is
// installed; the app's primary path launches real Chrome directly from the launcher,
// which is what makes passkeys / non-password Google sign-in work). Opens
// music.youtube.com in a clean, dedicated "app" window; login persists via a private
// user-data profile.
const { chromium } = require('playwright');
const path = require('path');
const os = require('os');
const fs = require('fs');

const TARGET = 'https://music.youtube.com/';
const SUPPORT = path.join(os.homedir(), 'Library', 'Application Support', 'YouTube Music');
const userDataDir = path.join(SUPPORT, 'profile');
fs.mkdirSync(userDataDir, { recursive: true });

// Normally unset on this fallback path → Playwright's bundled Chromium. (Real Chrome is
// handled directly by the launcher, not here.) Honor YTM_CHANNEL if something sets it.
const channel = process.env.YTM_CHANNEL || undefined;

const args = [
  '--app=' + TARGET,                          // chromeless, dedicated app window
  '--start-maximized',
  '--no-first-run',
  '--no-default-browser-check',
  '--disable-blink-features=AutomationControlled',
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
  const launchOpts = {
    headless: false,
    viewport: null,                           // page fills the real window
    ignoreDefaultArgs: ['--enable-automation'], // no "controlled by automation" banner; webdriver=false
    args,
  };
  if (channel) launchOpts.channel = channel;

  const context = await chromium.launchPersistentContext(userDataDir, launchOpts);

  // Locate the app window; tolerate Playwright's initial page racing the --app window.
  let page = context.pages().find((p) => /music\.youtube\.com/.test(p.url()))
          || context.pages()[0]
          || await context.waitForEvent('page', { timeout: 20000 });

  if (page && !/music\.youtube\.com/.test(page.url())) {
    await page.goto(TARGET, { waitUntil: 'domcontentloaded' }).catch(() => {});
  }

  // Remove any stray blank page Playwright may have opened alongside the app window.
  for (const p of context.pages()) {
    if (p !== page && (p.url() === 'about:blank' || p.url() === '')) {
      await p.close().catch(() => {});
    }
  }

  log(`ready (channel=${channel || 'bundled-chromium'})`);

  // Stay alive until the user closes the window / quits the app.
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
