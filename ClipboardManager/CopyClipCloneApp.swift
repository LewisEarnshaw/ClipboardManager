import SwiftUI

@main
struct CopyClipCloneApp: App {
    // AppKit delegate owns the menu bar item, popover, and global hotkey.
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // No visible window — the app lives entirely in the menu bar.
        Settings { EmptyView() }
    }
}
