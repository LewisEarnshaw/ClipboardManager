import AppKit
import Carbon.HIToolbox

/// Registers a single system-wide hotkey using Carbon's RegisterEventHotKey.
/// Carbon hotkeys work without the Accessibility permission that CGEvent taps need.
/// Call register() again at any time to switch to a different key combo.
final class HotKeyManager {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private let onFire: () -> Void

    init(onFire: @escaping () -> Void) {
        self.onFire = onFire
        installHandler()
    }

    /// Installed once; routes every hotkey press to onFire.
    private func installHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: OSType(kEventHotKeyPressed))
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        InstallEventHandler(GetApplicationEventTarget(), { _, _, userData -> OSStatus in
            guard let userData else { return noErr }
            let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
            manager.onFire()
            return noErr
        }, 1, &eventType, selfPtr, &eventHandler)
    }

    /// keyCode is a virtual key code (e.g. kVK_ANSI_V).
    /// modifiers combine Carbon flags (e.g. cmdKey | shiftKey).
    func register(keyCode: UInt32, modifiers: UInt32) {
        // Drop any previous registration so we don't stack hotkeys.
        if let existing = hotKeyRef {
            UnregisterEventHotKey(existing)
            hotKeyRef = nil
        }
        let hotKeyID = EventHotKeyID(signature: OSType(0x43434C50) /* 'CCLP' */, id: 1)
        RegisterEventHotKey(keyCode, modifiers, hotKeyID,
                            GetApplicationEventTarget(), 0, &hotKeyRef)
    }

    deinit {
        if let hotKeyRef { UnregisterEventHotKey(hotKeyRef) }
        if let eventHandler { RemoveEventHandler(eventHandler) }
    }
}
