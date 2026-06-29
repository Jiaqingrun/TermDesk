import Foundation
import QRMetricsKit
import SysPeekShared
import TermDeskShared

enum SysSnapshotBridge {
    static func fromWidget(_ widget: WidgetSnapshot) -> SysSection {
        SysSection(
            source: "SysPeek",
            pCoreLoad: widget.pCoreLoad,
            eCoreLoad: widget.eCoreLoad,
            memoryPressure: widget.memoryPressure,
            gpuActivity: widget.gpuActivity,
            foregroundApp: widget.foregroundApp,
            ollamaOnline: widget.ollamaOnline,
            ollamaModels: widget.ollamaModels,
            volumes: widget.volumes.map {
                SysVolumeEntry(name: $0.name, connected: $0.connected, freePercent: $0.freePercent)
            }
        )
    }

    static func fromMetrics(_ metrics: MetricsSnapshot) -> SysSection {
        SysSection(
            source: "TermDesk",
            pCoreLoad: metrics.cpu.performanceCoreLoad,
            eCoreLoad: metrics.cpu.efficiencyCoreLoad,
            memoryPressure: metrics.memory.pressure.rawValue,
            gpuActivity: metrics.gpu.activityLevel.rawValue,
            foregroundApp: metrics.foregroundApp.name.isEmpty ? nil : metrics.foregroundApp.name,
            ollamaOnline: metrics.ollama.isOnline,
            ollamaModels: metrics.ollama.loadedModels.map(\.name),
            volumes: metrics.volumes.map {
                SysVolumeEntry(
                    name: $0.displayName,
                    connected: $0.connectionState == .connected,
                    freePercent: $0.freePercent
                )
            }
        )
    }
}
