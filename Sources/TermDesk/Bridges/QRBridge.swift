import Foundation
import TermDeskShared

enum QRBridge {
    private static let notesDirectory = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".qr/notes", isDirectory: true)

    static func load() -> QRSection {
        let doctor = runDoctor()
        let notes = loadRecentNotes(limit: 5)
        return QRSection(
            doctorOK: doctor.issueCount == 0,
            issueCount: doctor.issueCount,
            doctorLines: doctor.lines,
            recentNotes: notes
        )
    }

    private static func runDoctor() -> (issueCount: Int, lines: [String]) {
        let pipe = Pipe()
        let process = Process()
        if let qrPath = resolveQRPath() {
            process.executableURL = URL(fileURLWithPath: qrPath)
            process.arguments = ["doctor"]
        } else {
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = ["qr", "doctor"]
        }
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
        } catch {
            return (1, ["无法运行 qr doctor：\(error.localizedDescription)"])
        }

        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        var issueCount = 0
        var lines: [String] = []

        for line in output.split(separator: "\n", omittingEmptySubsequences: false) {
            let text = String(line).trimmingCharacters(in: .whitespaces)
            if text.hasPrefix("✓") {
                if lines.count < 6 { lines.append(text) }
            } else if text.contains("warn") || text.contains("│") && text.contains("warn") {
                issueCount += 1
            }
        }

        if lines.isEmpty {
            lines = output.split(separator: "\n").prefix(8).map(String.init)
        }

        if issueCount == 0 {
            for row in output.split(separator: "\n") {
                let text = String(row)
                if text.contains("│") && (text.contains(" warn ") || text.contains("│ warn")) {
                    issueCount += 1
                }
            }
        }

        if issueCount == 0 && output.contains("待完善项") {
            issueCount = output.components(separatedBy: "│ warn").count - 1
            if issueCount < 0 { issueCount = 0 }
        }

        return (max(issueCount, 0), Array(lines.prefix(8)))
    }

    private static func loadRecentNotes(limit: Int) -> [QRNoteEntry] {
        guard FileManager.default.fileExists(atPath: notesDirectory.path) else { return [] }

        guard let files = try? FileManager.default.contentsOfDirectory(
            at: notesDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        let sorted = files
            .filter { $0.pathExtension == "md" }
            .sorted { lhs, rhs in
                let lDate = (try? lhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
                let rDate = (try? rhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
                return lDate > rDate
            }
            .prefix(limit)

        return sorted.map { url in
            let text = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
            let title = text.split(separator: "\n").first.map { line in
                String(line).trimmingCharacters(in: CharacterSet(charactersIn: "# "))
            } ?? url.deletingPathExtension().lastPathComponent
            let preview = text
                .replacingOccurrences(of: "\n", with: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let modified = (try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date()
            return QRNoteEntry(
                id: url.lastPathComponent,
                title: title.isEmpty ? url.lastPathComponent : title,
                modifiedAt: modified,
                preview: String(preview.prefix(120))
            )
        }
    }

    private static func resolveQRPath() -> String? {
        let candidates = [
            "/opt/anaconda3/bin/qr",
            "/usr/local/bin/qr",
            "/opt/homebrew/bin/qr",
        ]
        for path in candidates where FileManager.default.isExecutableFile(atPath: path) {
            return path
        }
        return nil
    }

    static func qrExecutablePath() -> String {
        resolveQRPath() ?? "/opt/anaconda3/bin/qr"
    }
}
