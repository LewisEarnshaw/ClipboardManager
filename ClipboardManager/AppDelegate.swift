import SwiftUI
import AppKit
import Combine
import Carbon.HIToolbox

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()
    private var clipboard: ClipboardManager!
    private var hotKey: HotKeyManager?
    private var preferencesWindow: NSWindow?
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        let settings = AppSettings.shared
        clipboard = ClipboardManager(maxItems: settings.maxItems)

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
            rootView: ClipboardMenu(
                clipboard: clipboard,
                onOpenPreferences: { [weak self] in self?.openPreferences() }
            )
        )

        // Global hotkey manager (key combo applied by the subscription below)
        hotKey = HotKeyManager { [weak self] in
            self?.togglePopover()
        }

        // Apply settings now and re-apply whenever they change.
        // A @Published publisher delivers its current value on subscribe,
        // so these fire once immediately to set the initial state.
        settings.$maxItems
            .sink { [weak self] value in
                self?.clipboard.updateMaxItems(value)
            }
            .store(in: &cancellables)

        settings.$hotKeyID
            .sink { [weak self] id in
                let option = HotKeyOption(rawValue: id) ?? .cmdShiftV
                self?.hotKey?.register(keyCode: option.keyCode, modifiers: option.modifiers)
            }
            .store(in: &cancellables)
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    /// Opens a self-managed Preferences window and forces it to the front.
    /// Agent (menu-bar-only) apps need the activation-policy switch, otherwise
    /// the window opens hidden behind other apps.
    @objc private func openPreferences() {
        popover.performClose(nil)

        if preferencesWindow == nil {
            let hosting = NSHostingController(rootView: PreferencesView())
            let window = NSWindow(contentViewController: hosting)
            window.title = "Preferences"
            window.styleMask = [.titled, .closable]
            window.isReleasedWhenClosed = false
            window.delegate = self
            preferencesWindow = window
        }

        NSApp.setActivationPolicy(.regular)          // let the window come forward
        NSApp.activate(ignoringOtherApps: true)
        preferencesWindow?.center()
        preferencesWindow?.makeKeyAndOrderFront(nil)
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        // Drop back to menu-bar-only mode (no Dock icon) when Preferences closes.
        NSApp.setActivationPolicy(.accessory)
    }
}
