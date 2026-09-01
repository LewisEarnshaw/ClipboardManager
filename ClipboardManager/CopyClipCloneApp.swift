import SwiftUI

@main
struct CopyClipCloneApp: App {
    // AppKit delegate owns the menu bar item, popover, and global hotkey.
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // The Settings scene renders as the standard Preferences window (⌘,).
        Settings {
            PreferencesView()
        }
    }
}
