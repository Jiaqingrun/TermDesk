import Foundation

public enum TermDeskPaths {
    public static var applicationSupportDirectory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("TermDesk", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    /// mac-dashboard-agent 与 Pi 仪表盘读取的统一快照。
    public static var snapshotURL: URL {
        applicationSupportDirectory.appendingPathComponent("snapshot.json")
    }

    public static var fleetStatusURL: URL {
        applicationSupportDirectory.appendingPathComponent("fleet-status.json")
    }
}
