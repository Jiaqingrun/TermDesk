import Foundation
import QRMetricsKit
import SysPeekShared
import TermDeskShared

@MainActor
final class TermDeskStore: ObservableObject {
    @Published private(set) var snapshot: TermDeskSnapshot = .empty
    @Published var panelOpen = false
    @Published var selectedTab: DashboardTab = .sys

    private let sampler = MetricsSampler()
    private var loopTask: Task<Void, Never>?
    private var lastQRRefresh: Date = .distantPast
    private var cachedQR = QRSection(doctorOK: true, issueCount: 0, doctorLines: [], recentNotes: [])

    init() {
        Task { @MainActor in self.start() }
    }

    func start() {
        guard loopTask == nil else { return }
        loopTask = Task { @MainActor [weak self] in
            await self?.runLoop()
        }
    }

    func stop() {
        loopTask?.cancel()
        loopTask = nil
    }

    private func runLoop() async {
        while !Task.isCancelled {
            let panelOpen = self.panelOpen
            let interval = TermDeskRefreshPolicy.interval(panelOpen: panelOpen)

            let sys = await loadSysSection(panelOpen: panelOpen, interval: interval)
            if Date().timeIntervalSince(lastQRRefresh) >= TermDeskRefreshPolicy.qrRefreshInterval || panelOpen {
                cachedQR = QRBridge.load()
                lastQRRefresh = Date()
            }
            let fleet = FleetBridge.load()

            let combined = TermDeskSnapshot(
                updatedAt: Date(),
                sys: sys,
                qr: cachedQR,
                fleet: fleet
            )
            snapshot = combined
            TermDeskSnapshotWriter.write(combined)

            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
        }
    }

    private func loadSysSection(panelOpen: Bool, interval: TimeInterval) async -> SysSection? {
        if let widget = WidgetSnapshotReader.load(),
           Date().timeIntervalSince(widget.updatedAt) <= TermDeskRefreshPolicy.widgetStaleThreshold {
            return SysSnapshotBridge.fromWidget(widget)
        }

        let metrics = await sampler.sample(refreshInterval: interval, panelOpen: panelOpen)
        return SysSnapshotBridge.fromMetrics(metrics)
    }
}

extension TermDeskSnapshot {
    static let empty = TermDeskSnapshot(
        updatedAt: .distantPast,
        sys: nil,
        qr: QRSection(doctorOK: true, issueCount: 0, doctorLines: ["加载中…"], recentNotes: []),
        fleet: FleetSection(
            agentConfigured: false,
            lastPushAt: nil,
            lastPushChannel: "unknown",
            lastPushOK: false,
            piURL: nil
        )
    )
}

enum DashboardTab: String, CaseIterable, Identifiable {
    case sys = "SYS"
    case qr = "QR"
    case shell = "SHELL"
    case fleet = "FLEET"

    var id: String { rawValue }
}
