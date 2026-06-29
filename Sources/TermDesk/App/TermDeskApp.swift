import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    var store: TermDeskStore?

    func applicationDidFinishLaunching(_ notification: Notification) {
        HotkeyManager.shared.onTogglePanel = { [weak self] in
            if let store = self?.store {
                FloatingPanelController.shared.attach(store: store)
            }
            FloatingPanelController.shared.toggle()
        }
        HotkeyManager.shared.register()
    }

    func applicationWillTerminate(_ notification: Notification) {
        HotkeyManager.shared.unregister()
        store?.stop()
    }
}

private struct MenuBarIconView: View {
    @ObservedObject var store: TermDeskStore

    var body: some View {
        Image(nsImage: MenuBarIconRenderer.makeImage(sys: store.snapshot.sys))
    }
}

@main
struct TermDeskApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = TermDeskStore()
    @AppStorage("termdesk.menuBarCompact") private var menuBarCompact = TermDeskSettings.menuBarCompact
    @AppStorage("termdesk.preferSysPeek") private var preferSysPeek = TermDeskSettings.preferSysPeekSnapshot
    @AppStorage("termdesk.floatingPinned") private var floatingPinned = TermDeskSettings.floatingPinned
    @AppStorage("termdesk.floatingEdge") private var floatingEdge = TermDeskSettings.floatingEdge

    var body: some Scene {
        MenuBarExtra {
            if menuBarCompact {
                CompactMenuBarView(store: store) {
                    openFloatingPanel()
                }
                .onAppear { store.panelOpen = true }
                .onDisappear { store.panelOpen = false }
            } else {
                DashboardView(store: store, compact: true)
                    .onAppear { panelDidOpen() }
                    .onDisappear { store.panelOpen = false }
            }
        } label: {
            MenuBarIconView(store: store)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(
                store: store,
                menuBarCompact: $menuBarCompact,
                preferSysPeek: $preferSysPeek,
                floatingPinned: $floatingPinned,
                floatingEdge: $floatingEdge
            )
        }
    }

    private func panelDidOpen() {
        store.panelOpen = true
        appDelegate.store = store
        FloatingPanelController.shared.attach(store: store)
    }

    private func openFloatingPanel() {
        appDelegate.store = store
        FloatingPanelController.shared.attach(store: store)
        FloatingPanelController.shared.show()
    }
}

private struct CompactMenuBarView: View {
    @ObservedObject var store: TermDeskStore
    let openFloating: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TermDesk")
                .font(.headline)
            Text("精简菜单栏模式")
                .font(TermDeskTheme.monoSmall)
                .foregroundStyle(TermDeskTheme.muted)
            Button("打开悬浮控制台\t⌘⇧`") {
                openFloating()
            }
            .keyboardShortcut("`", modifiers: [.command, .shift])
            if let sys = store.snapshot.sys {
                Text(String(format: "P %.0f%% · E %.0f%% · %@", sys.pCoreLoad, sys.eCoreLoad, sys.source))
                    .font(TermDeskTheme.monoSmall)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(width: 260, alignment: .leading)
        .background(TermDeskTheme.panelBackground)
    }
}

private struct SettingsView: View {
    @ObservedObject var store: TermDeskStore
    @Binding var menuBarCompact: Bool
    @Binding var preferSysPeek: Bool
    @Binding var floatingPinned: Bool
    @Binding var floatingEdge: String
    @State private var loginItemEnabled = LoginItemManager.isEnabled
    @State private var loginItemStatus = LoginItemManager.status.label
    @State private var loginItemError: String?

    private let edgeOptions = [
        ("right", "贴右边缘"),
        ("left", "贴左边缘"),
        ("free", "自由拖动"),
    ]

    var body: some View {
        Form {
            Section("登录项") {
                Toggle("登录时打开 TermDesk", isOn: $loginItemEnabled)
                    .onChange(of: loginItemEnabled) { _, enabled in
                        updateLoginItem(enabled: enabled)
                    }
                Text("状态：\(loginItemStatus)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let loginItemError {
                    Text(loginItemError).font(.caption).foregroundStyle(.red)
                }
                Button("打开系统登录项设置…") {
                    LoginItemManager.openSystemSettings()
                }
            }

            Section("菜单栏") {
                Toggle("精简模式（popover 仅快捷入口）", isOn: $menuBarCompact)
                    .onChange(of: menuBarCompact) { _, value in
                        TermDeskSettings.menuBarCompact = value
                    }
            }

            Section("悬浮窗") {
                Toggle("钉住（失焦不自动隐藏）", isOn: $floatingPinned)
                    .onChange(of: floatingPinned) { _, value in
                        TermDeskSettings.floatingPinned = value
                        FloatingPanelController.shared.refreshBehavior()
                    }
                Picker("贴边", selection: $floatingEdge) {
                    ForEach(edgeOptions, id: \.0) { value, label in
                        Text(label).tag(value)
                    }
                }
                .onChange(of: floatingEdge) { _, value in
                    TermDeskSettings.floatingEdge = value
                    FloatingPanelController.shared.refreshBehavior()
                }
            }

            Section("采样") {
                Toggle("优先 SysPeek 快照（过期时不自行采样）", isOn: $preferSysPeek)
                    .onChange(of: preferSysPeek) { _, value in
                        TermDeskSettings.preferSysPeekSnapshot = value
                    }
            }

            Section("快捷键") {
                Text("⌘⇧` 打开/关闭悬浮控制台")
                    .font(.caption)
            }

            Section("数据") {
                Text("~/Library/Application Support/TermDesk/snapshot.json")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Section("关联") {
                Button("打开 QR Web") {
                    NSWorkspace.shared.open(URL(string: "http://127.0.0.1:8765")!)
                }
                Button("打开悬浮控制台") {
                    FloatingPanelController.shared.attach(store: store)
                    FloatingPanelController.shared.show()
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 460, height: 480)
        .padding()
        .onAppear {
            loginItemEnabled = LoginItemManager.isEnabled
            loginItemStatus = LoginItemManager.status.label
        }
    }

    private func updateLoginItem(enabled: Bool) {
        do {
            try LoginItemManager.setEnabled(enabled)
            loginItemError = nil
            loginItemEnabled = LoginItemManager.isEnabled
            loginItemStatus = LoginItemManager.status.label
        } catch {
            loginItemError = error.localizedDescription
            loginItemEnabled = LoginItemManager.isEnabled
        }
    }
}
