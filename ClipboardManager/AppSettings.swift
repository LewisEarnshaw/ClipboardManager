import Foundation
import Combine
import Carbon.HIToolbox

/// The set of preset shortcuts the user can pick from in Preferences.
enum HotKeyOption: String, CaseIterable, Identifiable {
    case cmdShiftV
    case cmdShiftC
    case optShiftV
    case ctrlShiftV
    case cmdShiftSpace

    var id: String { rawValue }

    var label: String {
        switch self {
        case .cmdShiftV:     return "⌘⇧V"
        case .cmdShiftC:     return "⌘⇧C"
        case .optShiftV:     return "⌥⇧V"
        case .ctrlShiftV:    return "⌃⇧V"
        case .cmdShiftSpace: return "⌘⇧Space"
        }
    }

    var keyCode: UInt32 {
        switch self {
        case .cmdShiftV, .optShiftV, .ctrlShiftV: return UInt32(kVK_ANSI_V)
        case .cmdShiftC:                          return UInt32(kVK_ANSI_C)
        case .cmdShiftSpace:                      return UInt32(kVK_Space)
        }
    }

    // Carbon modifier flags.
    var modifiers: UInt32 {
        switch self {
        case .cmdShiftV, .cmdShiftC, .cmdShiftSpace: return UInt32(cmdKey | shiftKey)
        case .optShiftV:                             return UInt32(optionKey | shiftKey)
        case .ctrlShiftV:                            return UInt32(controlKey | shiftKey)
        }
    }
}

/// Single source of truth for user preferences, backed by UserDefaults.
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var maxItems: Int {
        didSet { UserDefaults.standard.set(maxItems, forKey: "maxItems") }
    }

    @Published var hotKeyID: String {
        didSet { UserDefaults.standard.set(hotKeyID, forKey: "hotKeyID") }
    }

    /// The currently selected shortcut as a strongly-typed option.
    var hotKey: HotKeyOption { HotKeyOption(rawValue: hotKeyID) ?? .cmdShiftV }

    private init() {
        let defaults = UserDefaults.standard
        maxItems = defaults.object(forKey: "maxItems") as? Int ?? 50
        hotKeyID = defaults.string(forKey: "hotKeyID") ?? HotKeyOption.cmdShiftV.rawValue
    }
}
