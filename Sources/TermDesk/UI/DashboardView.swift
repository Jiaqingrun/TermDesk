import SwiftUI
import TermDeskShared

struct DashboardView: View {
    @ObservedObject var store: TermDeskStore
    var compact: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            header
            tabBar
            tabContent
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
        }
        .background(TermDeskTheme.panelBackground)
        .termDeskPanelFrame(width: compact ? 380 : 440)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("TermDesk")
                    .font(.headline)
                Text("personal console")
                    .font(TermDeskTheme.monoSmall)
                    .foregroundStyle(TermDeskTheme.muted)
            }
            Spacer()
            Text(store.snapshot.updatedAt, style: .time)
                .font(TermDeskTheme.monoSmall)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(DashboardTab.allCases) { tab in
                Button {
                    store.selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(TermDeskTheme.monoSmall)
                        .foregroundStyle(store.selectedTab == tab ? TermDeskTheme.lime : TermDeskTheme.muted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(store.selectedTab == tab ? TermDeskTheme.lime.opacity(0.08) : Color.clear)
                }
                .buttonStyle(.plain)
            }
        }
        .background(TermDeskTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch store.selectedTab {
        case .sys:
            SysTabView(section: store.snapshot.sys)
        case .qr:
            QRTabView(section: store.snapshot.qr)
        case .shell:
            ShellTabView()
        case .fleet:
            FleetTabView(section: store.snapshot.fleet)
        }
    }
}

struct SysTabView: View {
    let section: SysSection?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let section {
                BracketSectionHeader(title: "SYS", accent: TermDeskTheme.lime)
                HStack {
                    metricChip("P", value: section.pCoreLoad)
                    metricChip("E", value: section.eCoreLoad)
                    Spacer()
                    Text(section.source)
                        .font(TermDeskTheme.monoSmall)
                        .foregroundStyle(.tertiary)
                }
                row("内存", trailing: section.memoryPressure) {
                    MetricBar(fraction: pressureFraction(section.memoryPressure), tint: TermDeskTheme.pressureColor(section.memoryPressure))
                }
                row("GPU", trailing: section.gpuActivity) {
                    MetricBar(fraction: 0.35, tint: Color.purple.opacity(0.8))
                }
                if let app = section.foregroundApp, !app.isEmpty {
                    Text("前台 · \(app)")
                        .font(TermDeskTheme.monoSmall)
                        .foregroundStyle(TermDeskTheme.muted)
                        .lineLimit(1)
                }
                if section.ollamaOnline {
                    Text("Ollama · \(section.ollamaModels.joined(separator: ", "))")
                        .font(TermDeskTheme.monoSmall)
                        .foregroundStyle(TermDeskTheme.lime)
                        .lineLimit(2)
                }
                if !section.volumes.isEmpty {
                    Divider().opacity(0.25)
                    ForEach(section.volumes, id: \.name) { vol in
                        HStack {
                            Text(vol.name)
                                .font(TermDeskTheme.monoSmall)
                            Spacer()
                            if vol.connected, let pct = vol.freePercent {
                                Text(String(format: "%.0f%% 空闲", pct))
                                    .font(TermDeskTheme.monoSmall)
                                    .foregroundStyle(TermDeskTheme.muted)
                            } else {
                                Text("断开")
                                    .font(TermDeskTheme.monoSmall)
                                    .foregroundStyle(TermDeskTheme.rose)
                            }
                        }
                    }
                }
            } else {
                Text("等待 SysPeek 或本地采样…")
                    .font(TermDeskTheme.monoSmall)
                    .foregroundStyle(TermDeskTheme.muted)
            }
        }
    }

    private func metricChip(_ label: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(label) \(Int(value))%")
                .font(TermDeskTheme.monoSmall)
            MetricBar(fraction: value / 100, tint: TermDeskTheme.lime)
                .frame(width: 72)
        }
    }

    private func row<Content: View>(_ label: String, trailing: String, @ViewBuilder bar: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label).font(TermDeskTheme.monoSmall)
                Spacer()
                Text(trailing).font(TermDeskTheme.monoSmall).foregroundStyle(TermDeskTheme.muted)
            }
            bar()
        }
    }

    private func pressureFraction(_ raw: String) -> Double {
        switch raw {
        case "critical": return 0.95
        case "warning": return 0.75
        default: return 0.45
        }
    }
}

struct QRTabView: View {
    let section: QRSection

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            BracketSectionHeader(title: "QR", accent: TermDeskTheme.lime)
            HStack {
                Circle()
                    .fill(section.doctorOK ? TermDeskTheme.lime : TermDeskTheme.rose)
                    .frame(width: 8, height: 8)
                Text(section.doctorOK ? "doctor 通过" : "待完善 \(section.issueCount) 项")
                    .font(TermDeskTheme.monoSmall)
            }
            VStack(alignment: .leading, spacing: 4) {
                ForEach(section.doctorLines, id: \.self) { line in
                    Text(line)
                        .font(TermDeskTheme.monoSmall)
                        .foregroundStyle(TermDeskTheme.muted)
                        .lineLimit(1)
                }
            }
            Divider().opacity(0.25)
            Text("最近笔记")
                .font(TermDeskTheme.monoSmall)
                .foregroundStyle(TermDeskTheme.lime)
            if section.recentNotes.isEmpty {
                Text("无 ~/.qr/notes")
                    .font(TermDeskTheme.monoSmall)
                    .foregroundStyle(.tertiary)
            } else {
                ForEach(section.recentNotes) { note in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(note.title)
                            .font(.caption)
                            .lineLimit(1)
                        Text(note.preview)
                            .font(TermDeskTheme.monoSmall)
                            .foregroundStyle(.tertiary)
                            .lineLimit(2)
                    }
                }
            }
            Button("打开 QR Web") {
                if let url = URL(string: "http://127.0.0.1:8765") {
                    NSWorkspace.shared.open(url)
                }
            }
            .font(TermDeskTheme.monoSmall)
            .buttonStyle(.plain)
            .foregroundStyle(TermDeskTheme.lime)
        }
    }
}

struct FleetTabView: View {
    let section: FleetSection

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            BracketSectionHeader(title: "FLEET", accent: TermDeskTheme.lime)
            statusRow("Agent 配置", value: section.agentConfigured ? "已找到 config.yaml" : "未配置")
            statusRow("Pi 地址", value: section.piURL ?? "—")
            statusRow("推送通道", value: section.lastPushChannel)
            statusRow("最近推送", value: pushLabel)
            HStack {
                Circle()
                    .fill(section.lastPushOK ? TermDeskTheme.lime : TermDeskTheme.rose)
                    .frame(width: 8, height: 8)
                Text(section.lastPushOK ? "Pi 在线" : "等待 mac-dashboard-agent")
                    .font(TermDeskTheme.monoSmall)
            }
        }
    }

    private var pushLabel: String {
        guard let date = section.lastPushAt else { return "—" }
        return date.formatted(date: .omitted, time: .standard)
    }

    private func statusRow(_ label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(TermDeskTheme.monoSmall)
                .foregroundStyle(TermDeskTheme.muted)
                .frame(width: 72, alignment: .leading)
            Text(value)
                .font(TermDeskTheme.monoSmall)
                .lineLimit(2)
            Spacer(minLength: 0)
        }
    }
}

import AppKit
