import Foundation
import TermDeskShared

enum FleetBridge {
    private static let agentConfigPath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("QR/dev/mac-dashboard-agent/config.yaml")

    static func load() -> FleetSection {
        let status = loadAgentStatus()
        let configured = FileManager.default.fileExists(atPath: agentConfigPath.path)
        let piURL = parsePiURL()

        return FleetSection(
            agentConfigured: configured,
            lastPushAt: status?.lastPushAt,
            lastPushChannel: status?.channel ?? "unknown",
            lastPushOK: status?.ok ?? false,
            piURL: piURL
        )
    }

    private struct AgentStatus: Decodable {
        var lastPushAt: Date?
        var channel: String
        var ok: Bool

        enum CodingKeys: String, CodingKey {
            case lastPushAt, channel, ok
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            channel = try container.decode(String.self, forKey: .channel)
            ok = try container.decode(Bool.self, forKey: .ok)
            if let unix = try container.decodeIfPresent(Double.self, forKey: .lastPushAt) {
                lastPushAt = Date(timeIntervalSince1970: unix)
            } else {
                lastPushAt = nil
            }
        }
    }

    private static func loadAgentStatus() -> AgentStatus? {
        guard let data = try? Data(contentsOf: TermDeskPaths.fleetStatusURL) else { return nil }
        return try? JSONDecoder().decode(AgentStatus.self, from: data)
    }

    private static func parsePiURL() -> String? {
        guard let text = try? String(contentsOf: agentConfigPath, encoding: .utf8) else { return nil }
        for line in text.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("pi_url:") {
                return trimmed
                    .replacingOccurrences(of: "pi_url:", with: "")
                    .trimmingCharacters(in: CharacterSet(charactersIn: " \"'"))
            }
        }
        return nil
    }
}
