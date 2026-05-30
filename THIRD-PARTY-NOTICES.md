# Third-Party Notices

This project's own source code is licensed under the MIT License (see [LICENSE](LICENSE)). The
project itself **bundles and redistributes no third-party software** — the items below are either
downloaded at runtime onto the user's own machine, or are trademarks used only for identification.

## Browser engine — Chromium / Google Chrome for Testing

The app runs the YouTube Music website inside a Chromium-based engine, specifically **Google
Chrome for Testing**.

- © The Chromium Authors and Google LLC.
- Chromium is open-source software licensed under the **BSD 3-Clause License**:
  https://chromium.googlesource.com/chromium/src/+/refs/heads/main/LICENSE
- It is **downloaded at runtime** from Google's official Chrome for Testing distribution
  (`https://storage.googleapis.com/chrome-for-testing-public/...`), or reused from a copy already
  present on the user's machine. It is **not** included in or redistributed by this repository.
- "Google Chrome" and "Chrome for Testing" are trademarks of Google LLC.

## YouTube Music name and logo

- The "YouTube" and "YouTube Music" names, and the YouTube Music logo (`icon.svg`, `app.icns` in
  this repository), are **trademarks of Google LLC**.
- They are included **only** as the application's name and icon, for identification of the service
  the app opens. They are **not** claimed by the author and are **not** covered by this project's
  MIT license. See [DISCLAIMER.md](DISCLAIMER.md).

## macOS system tools

Standard macOS tools are invoked at build/runtime (`codesign`, `/usr/libexec/PlistBuddy`,
`iconutil`, `sips`, and optionally `rsvg-convert`). They are the property of their respective
owners and are used as installed on the system; none are redistributed by this repository.
