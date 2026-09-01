import SwiftUI

struct ClipboardMenu: View {
    @ObservedObject var clipboard: ClipboardManager
    @StateObject private var launch = LaunchAtLogin()
    @State private var search = ""
    @State private var justCopied = false

    // Search filter, then pinned clips floated to the top.
    private var ordered: [ClipItem] {
        let base = search.isEmpty
            ? clipboard.history
            : clipboard.history.filter { $0.text.localizedCaseInsensitiveContains(search) }
        return base.filter { $0.isPinned } + base.filter { !$0.isPinned }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search field
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search clips…", text: $search)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            Divider()

            // History list
            if ordered.isEmpty {
                Text(clipboard.history.isEmpty ? "No clips yet" : "No matches")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(ordered) { item in
                            ClipRow(
                                item: item,
                                onCopy: { copy(item) },
                                onDelete: { clipboard.delete(item) },
                                onTogglePin: { clipboard.togglePin(item) }
                            )
                            Divider()
                        }
                    }
                }
                .frame(height: 300)
            }

            Divider()

            // "Copied!" confirmation — the only visible feedback in a menu-bar app.
            if justCopied {
                Label("Copied to clipboard", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .transition(.opacity)
            }

            // Settings row
            Toggle("Launch at login", isOn: Binding(
                get: { launch.isEnabled },
                set: { launch.set($0) }
            ))
            .toggleStyle(.switch)
            .controlSize(.small)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)

            Divider()

            // Footer actions
            HStack {
                Button("Clear Unpinned") { clipboard.clearHistory() }
                    .buttonStyle(.plain)
                    .foregroundStyle(.red)
                Spacer()
                Text("⌘⇧V")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Quit") { NSApplication.shared.terminate(nil) }
                    .buttonStyle(.plain)
            }
            .padding(8)
        }
        .frame(width: 320)
    }

    private func copy(_ item: ClipItem) {
        clipboard.copyToClipboard(item)
        withAnimation { justCopied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation { justCopied = false }
        }
    }
}

private struct ClipRow: View {
    let item: ClipItem
    let onCopy: () -> Void
    let onDelete: () -> Void
    let onTogglePin: () -> Void
    @State private var hovering = false

    var body: some View {
        HStack(spacing: 6) {
            if item.isPinned {
                Image(systemName: "pin.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
            Text(item.text)
                .lineLimit(2)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
            if hovering {
                Button(action: onTogglePin) {
                    Image(systemName: item.isPinned ? "pin.slash" : "pin")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .help(item.isPinned ? "Unpin" : "Pin")

                Button(action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .help("Delete")
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .background(hovering ? Color.secondary.opacity(0.12) : Color.clear)
        .onHover { hovering = $0 }
        .onTapGesture { onCopy() }   // click a clip to re-copy it
    }
}
