import AppKit
import SwiftTerm
import SwiftUI

struct ShellTabView: View {
    @State private var terminalReady = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            BracketSectionHeader(title: "SHELL", accent: TermDeskTheme.lime)
            TerminalHostView()
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
            HStack(spacing: 8) {
                ForEach(["doctor", "usage", "log \"activity\" --type activity -p dev/term-desk"], id: \.self) { cmd in
                    ShellChip(title: cmd.components(separatedBy: " ").first ?? cmd) {
                        NotificationCenter.default.post(name: .termDeskShellCommand, object: cmd)
                    }
                }
            }
        }
    }
}

private struct ShellChip: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .font(TermDeskTheme.monoSmall)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(TermDeskTheme.lime.opacity(0.12))
            .foregroundStyle(TermDeskTheme.lime)
            .clipShape(Capsule())
            .buttonStyle(.plain)
    }
}

extension Notification.Name {
    static let termDeskShellCommand = Notification.Name("TermDesk.shellCommand")
}

struct TerminalHostView: NSViewRepresentable {
    func makeNSView(context: Context) -> TerminalContainerView {
        let view = TerminalContainerView()
        view.start()
        return view
    }

    func updateNSView(_ nsView: TerminalContainerView, context: Context) {}
}

final class TerminalContainerView: NSView {
    private var terminal: LocalProcessTerminalView?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor(red: 0.05, green: 0.06, blue: 0.07, alpha: 1).cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func start() {
        guard terminal == nil else { return }
        let term = LocalProcessTerminalView(frame: bounds)
        term.autoresizingMask = [.width, .height]
        term.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        term.nativeForegroundColor = NSColor(red: 0.85, green: 0.9, blue: 0.8, alpha: 1)
        term.nativeBackgroundColor = NSColor(red: 0.05, green: 0.06, blue: 0.07, alpha: 1)
        addSubview(term)
        let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        term.startProcess(
            executable: shell,
            args: ["-l"],
            environment: [
                "TERM=xterm-256color",
                "PATH=\(ProcessInfo.processInfo.environment["PATH"] ?? "")",
                "HOME=\(FileManager.default.homeDirectoryForCurrentUser.path)",
            ]
        )
        terminal = term

        NotificationCenter.default.addObserver(
            forName: .termDeskShellCommand,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let cmd = note.object as? String else { return }
            self?.inject("qr \(cmd)\n")
        }
    }

    private func inject(_ text: String) {
        guard let terminal else { return }
        let bytes = Array(text.utf8)
        terminal.send(source: terminal, data: ArraySlice(bytes))
    }
}
