import SwiftUI
import AppKit
import Carbon.HIToolbox

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()
    private let clipboard = ClipboardManager(maxItems: 50)
    private var hotKey: HotKeyManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menu bar icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "paperclip",
                                   accessibilityDescription: "CopyClip")
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Popover that hosts the SwiftUI panel
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 320, height: 460)
        popover.contentViewController = NSHostingController(
            rootView: ClipboardMenu(clipboard: clipboard)
        )

        // Global hotkey: ⌘⇧V
        hotKey = HotKeyManager { [weak self] in
            self?.togglePopover()
        }
        hotKey?.register(keyCode: UInt32(kVK_ANSI_V),
                         modifiers: UInt32(cmdKey | shiftKey))
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            // Make the search field focusable immediately.
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
