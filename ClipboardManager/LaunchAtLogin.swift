import ServiceManagement
import Combine

/// Wraps macOS's modern login-item API (SMAppService, macOS 13+).
/// Registers the app itself to launch when the user logs in.
@MainActor
final class LaunchAtLogin: ObservableObject {
    @Published var isEnabled: Bool

    init() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    /// Turn launch-at-login on or off. Re-reads the real status afterward
    /// so the toggle always reflects what the system actually did.
    func set(_ enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
        } catch {
            print("Launch-at-login change failed: \(error.localizedDescription)")
        }
        isEnabled = SMAppService.mainApp.status == .enabled
    }
}
