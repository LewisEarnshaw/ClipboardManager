import SwiftUI
import AppKit

struct ClipboardMenu: View {
    @ObservedObject var clipboard: ClipboardManager
    let onOpenPreferences: () -> Void
    @StateObject private var launch = LaunchAtLogin()
    @ObservedObject private var settings = AppSettings.shared
    @State private var search = ""
    @State private var justCopied = false

    // Search filter, then pinned clips floated to the top.
    private var ordered: [ClipItem] {
        let base = search.isEmpty
            ? clipboard.history
            : clipboard.history.filter { matches($0, search) }
        return base.filter { $0.isPinned } + base.filter { !$0.isPinned }
    }

    private func matches(_ item: ClipItem, _ query: String) -> Bool {
        switch item.kind {
        case .text: return item.text.localizedCaseInsensitiveContains(query)
        case .file: return item.text.localizedCaseInsensitiveContains(query)
        case .image: return "image".localizedCaseInsensitiveContains(query)
        }
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
                                image: clipboard.image(for: item),
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

            // Current shortcut hint (reflects the Preferences choice)
            HStack {
                Text("Shortcut")
                Spacer()
                Text(settings.hotKey.label)
                    .foregroundStyle(.secondary)
            }
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.bottom, 6)

            Divider()

            // Footer actions
            HStack(spacing: 12) {
                Button("Clear Unpinned") { clipboard.clearHistory() }
                    .buttonStyle(.plain)
                    .foregroundStyle(.red)
                Spacer()
                Button("Preferences…") { onOpenPreferences() }
                    .buttonStyle(.plain)
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
    let image: NSImage?
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
            content
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

    // Renders differently depending on the clip type.
    @ViewBuilder private var content: some View {
        switch item.kind {
        case .text:
            Text(item.text)
                .lineLimit(2)
                .truncationMode(.tail)
        case .file:
            HStack(spacing: 6) {
                Image(systemName: "doc")
                    .foregroundStyle(.secondary)
                Text(URL(fileURLWithPath: item.text).lastPathComponent)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        case .image:
            HStack(spacing: 8) {
                if let image {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipped()
                        .cornerRadius(4)
                } else {
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
                Text("Image")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
