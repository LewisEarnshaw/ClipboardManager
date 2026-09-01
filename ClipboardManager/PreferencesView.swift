import SwiftUI

struct PreferencesView: View {
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        Form {
            Section {
                Stepper(value: $settings.maxItems, in: 10...200, step: 10) {
                    Text("History size: \(settings.maxItems) clips")
                }
                Text("Pinned clips are always kept, even beyond this limit.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text("History")
            }

            Section {
                Picker("Open panel", selection: $settings.hotKeyID) {
                    ForEach(HotKeyOption.allCases) { option in
                        Text(option.label).tag(option.rawValue)
                    }
                }
            } header: {
                Text("Shortcut")
            }
        }
        .formStyle(.grouped)
        .frame(width: 380, height: 260)
    }
}
