import Foundation

public struct TermDeskSnapshot: Codable, Sendable, Equatable {
    public var updatedAt: Date
    public var sys: SysSection?
    public var qr: QRSection
    public var fleet: FleetSection

    public init(updatedAt: Date, sys: SysSection?, qr: QRSection, fleet: FleetSection) {
        self.updatedAt = updatedAt
        self.sys = sys
        self.qr = qr
        self.fleet = fleet
    }
}

public struct SysSection: Codable, Sendable, Equatable {
    public var source: String
    public var pCoreLoad: Double
    public var eCoreLoad: Double
    public var memoryPressure: String
    public var gpuActivity: String
    public var foregroundApp: String?
    public var ollamaOnline: Bool
    public var ollamaModels: [String]
    public var volumes: [SysVolumeEntry]

    public init(
        source: String,
        pCoreLoad: Double,
        eCoreLoad: Double,
        memoryPressure: String,
        gpuActivity: String,
        foregroundApp: String?,
        ollamaOnline: Bool,
        ollamaModels: [String],
        volumes: [SysVolumeEntry]
    ) {
        self.source = source
        self.pCoreLoad = pCoreLoad
        self.eCoreLoad = eCoreLoad
        self.memoryPressure = memoryPressure
        self.gpuActivity = gpuActivity
        self.foregroundApp = foregroundApp
        self.ollamaOnline = ollamaOnline
        self.ollamaModels = ollamaModels
        self.volumes = volumes
    }
}

public struct SysVolumeEntry: Codable, Sendable, Equatable {
    public var name: String
    public var connected: Bool
    public var freePercent: Double?

    public init(name: String, connected: Bool, freePercent: Double?) {
        self.name = name
        self.connected = connected
        self.freePercent = freePercent
    }
}

public struct QRSection: Codable, Sendable, Equatable {
    public var doctorOK: Bool
    public var issueCount: Int
    public var doctorLines: [String]
    public var recentNotes: [QRNoteEntry]

    public init(doctorOK: Bool, issueCount: Int, doctorLines: [String], recentNotes: [QRNoteEntry]) {
        self.doctorOK = doctorOK
        self.issueCount = issueCount
        self.doctorLines = doctorLines
        self.recentNotes = recentNotes
    }
}

public struct QRNoteEntry: Codable, Sendable, Equatable, Identifiable {
    public var id: String
    public var title: String
    public var modifiedAt: Date
    public var preview: String

    public init(id: String, title: String, modifiedAt: Date, preview: String) {
        self.id = id
        self.title = title
        self.modifiedAt = modifiedAt
        self.preview = preview
    }
}

public struct FleetSection: Codable, Sendable, Equatable {
    public var agentConfigured: Bool
    public var lastPushAt: Date?
    public var lastPushChannel: String
    public var lastPushOK: Bool
    public var piURL: String?

    public init(
        agentConfigured: Bool,
        lastPushAt: Date?,
        lastPushChannel: String,
        lastPushOK: Bool,
        piURL: String?
    ) {
        self.agentConfigured = agentConfigured
        self.lastPushAt = lastPushAt
        self.lastPushChannel = lastPushChannel
        self.lastPushOK = lastPushOK
        self.piURL = piURL
    }
}

public enum TermDeskSnapshotWriter {
    public static func write(_ snapshot: TermDeskSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: TermDeskPaths.snapshotURL, options: .atomic)
    }

    public static func load() -> TermDeskSnapshot? {
        guard let data = try? Data(contentsOf: TermDeskPaths.snapshotURL) else { return nil }
        return try? JSONDecoder().decode(TermDeskSnapshot.self, from: data)
    }
}
