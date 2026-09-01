# ClipboardManager

A lightweight clipboard history manager for macOS that lives in your menu bar.
Copy anything — text, images, or files — and get it back later with a click or a
keyboard shortcut.

## Features

- **Captures text, images, and files** — screenshots and copied pictures appear
  as thumbnails; files copied in Finder appear as document rows.
- **Searchable history** — filter your clips as you type.
- **Pinned clips** — pin the ones you use often; they stay at the top and are
  never removed by the history limit or the Clear button.
- **Global hotkey** — open the panel from anywhere (default ⌘⇧V, configurable).
- **Launch at login** — optionally start automatically when you log in.
- **Skips passwords** — clips that apps mark as concealed/transient (e.g. from
  password managers) are ignored, so secrets never land in your history.
- **Preferences** — adjust history size and the shortcut from a settings window.
- **Local only** — history is stored on your Mac; nothing is sent anywhere.

## Requirements

- macOS 13 Ventura or later
- Xcode (recent version) to build from source

## Build & run

1. Open `ClipboardManager.xcodeproj` in Xcode.
2. Ensure **Application is agent (UIElement)** is set to `YES` in the target's
   Info settings (this makes it menu-bar-only, with no Dock icon).
3. Press **⌘R**. A paperclip icon appears in your menu bar.

## Install a permanent copy

1. In Xcode: **Product → Archive**.
2. In the Organizer: **Distribute App → Custom → Copy App → Export**.
3. Drag the exported `ClipboardManager.app` into `/Applications`.
4. First launch: right-click the app → **Open** to clear Gatekeeper.

## Usage

- Click the menu bar paperclip (or press the hotkey) to open the panel.
- Click any clip to copy it back to the clipboard, then paste as usual.
- Hover a clip to **pin** or **delete** it.
- Use **Preferences…** to change history size or the shortcut.

## Privacy

All clipboard history is stored locally: text and metadata in the app's
preferences, and captured images as files in the app's Application Support
folder. Nothing leaves your machine. Content that apps mark as a password or
transient value is never captured.

## Known limitations

- Copying multiple files at once stores only the first.
- Identical images are not de-duplicated (identical text and files are).
- The app is self-signed, so distributing it to other Macs requires signing and
  notarization (see below).

## License

MIT — see [LICENSE](LICENSE).
