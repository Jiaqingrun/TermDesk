import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    var store: TermDeskStore?

    func applicationDidFinishLaunching(_ notification: Notification) {
        HotkeyManager.shared.onTogglePanel = { [weak self] in
            FloatingPanelController.shared.toggle()
            if let store = self?.store {
                FloatingPanelController.shared.attach(store: store)
            }
        }
        HotkeyManager.shared.register()
    }

    func applicationWillTerminate(_ notification: Notification) {
        HotkeyManager.shared.unregister()
        store?.stop()
    }
}

@main
struct TermDeskApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = TermDeskStore()

    var body: some Scene {
        MenuBarExtra {
            DashboardView(store: store, compact: true)
                .onAppear {
                    store.panelOpen = true
                    appDelegate.store = store
                    FloatingPanelController.shared.attach(store: store)
                }
                .onDisappear {
                    store.panelOpen = false
                }
        } label: {
            Image(systemName: "terminal.fill")
                .symbolRenderingMode(.hierarchical)
        }
        .menuBarExtraStyle(.window)

        Settings {
            Form {
                Section("快捷键") {
                    Text("⌘⇧` 打开/关闭悬浮控制台")
                        .font(.caption)
                }
                Section("数据") {
                    Text("快照：~/Library/Application Support/TermDesk/snapshot.json")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Section("关联") {
                    Button("打开 QR Web") {
                        NSWorkspace.shared.open(URL(string: "http://127.0.0.1:8765")!)
                    }
                    Button("在 TermDesk 中打开完整面板") {
                        FloatingPanelController.shared.attach(store: store)
                        FloatingPanelController.shared.show()
                    }
                }
            }
            .formStyle(.grouped)
            .frame(width: 420, height: 280)
            .padding()
        }
    }
}
