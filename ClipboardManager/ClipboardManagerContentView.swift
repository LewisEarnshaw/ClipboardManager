//
//  ContentView.swift
//  ClipboardManager
//
//  Created by Lewis Earnshaw on 28/08/2026.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @State private var clipboardHistory: [String] = []
    @State private var timer: Timer?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Clipboard History")
                .font(.headline)
                .padding()

            Divider()

            if clipboardHistory.isEmpty {
                Text("Nothing copied yet.")
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                List(clipboardHistory, id: \.self) { item in
                    Button {
                        copyToPasteboard(item)
                    } label: {
                        Text(item)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
            }

            Divider()

            HStack {
                Button("Clear") {
                    clipboardHistory.removeAll()
                }
                .foregroundStyle(.red)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding()
        }
        .frame(width: 300, height: 400)
        .onAppear {
            startMonitoring()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    // MARK: - Clipboard Monitoring

    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            checkClipboard()
        }
    }

    private func checkClipboard() {
        guard let content = NSPasteboard.general.string(forType: .string) else { return }

        if clipboardHistory.first != content {
            clipboardHistory.insert(content, at: 0)

            // Keep history to a maximum of 50 items
            if clipboardHistory.count > 50 {
                clipboardHistory.removeLast()
            }
        }
    }

    private func copyToPasteboard(_ string: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
    }
}

#Preview {
    ContentView()
}
