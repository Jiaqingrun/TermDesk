import AppKit
import Carbon
import SwiftUI

final class HotkeyManager {
    static let shared = HotkeyManager()

    var onTogglePanel: (() -> Void)?

    private var hotKeyRef: EventHotKeyRef?
    private let hotKeyID = EventHotKeyID(signature: OSType(0x5444_534B), id: 1)
    private var eventHandlerRef: EventHandlerRef?

    private init() {}

    func register() {
        unregister()

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            hotKeyCallback,
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandlerRef
        )
        guard status == noErr else { return }

        let registerStatus = RegisterEventHotKey(
            UInt32(kVK_ANSI_Grave),
            UInt32(cmdKey | shiftKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        guard registerStatus == noErr else { return }
    }

    func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }
    }

    fileprivate func handleHotKey(_ hotKeyID: EventHotKeyID) {
        guard hotKeyID.signature == self.hotKeyID.signature, hotKeyID.id == self.hotKeyID.id else { return }
        DispatchQueue.main.async { [weak self] in
            self?.onTogglePanel?()
        }
    }
}

private func hotKeyCallback(
    _ handler: EventHandlerCallRef?,
    _ event: EventRef?,
    _ userData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let userData, let event else { return OSStatus(eventNotHandledErr) }
    var hotKeyID = EventHotKeyID()
    let status = GetEventParameter(
        event,
        EventParamName(kEventParamDirectObject),
        EventParamType(typeEventHotKeyID),
        nil,
        MemoryLayout<EventHotKeyID>.size,
        nil,
        &hotKeyID
    )
    guard status == noErr else { return status }

    let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
    manager.handleHotKey(hotKeyID)
    return noErr
}

@MainActor
final class FloatingPanelController: NSObject {
    static let shared = FloatingPanelController()

    private var panel: NSPanel?
    private weak var store: TermDeskStore?

    func attach(store: TermDeskStore) {
        self.store = store
    }

    func toggle() {
        if let panel, panel.isVisible {
            panel.orderOut(nil)
            store?.panelOpen = false
            return
        }
        show()
    }

    func show() {
        let panel = panel ?? makePanel()
        self.panel = panel
        applyBehavior(to: panel)
        applyEdgeSnap(to: panel)
        store?.panelOpen = true
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func refreshBehavior() {
        guard let panel else { return }
        applyBehavior(to: panel)
        applyEdgeSnap(to: panel)
    }

    private func makePanel() -> NSPanel {
        let hosting = NSHostingController(rootView: DashboardView(store: store!, compact: false))
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 440, height: 520),
            styleMask: [.nonactivatingPanel, .titled, .closable, .resizable, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        panel.title = "TermDesk"
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = NSColor(red: 0.05, green: 0.06, blue: 0.07, alpha: 0.94)
        panel.isOpaque = false
        panel.hasShadow = true
        panel.contentViewController = hosting
        panel.setFrameAutosaveName("TermDeskFloatingPanel")
        applyEdgeSnap(to: panel)
        return panel
    }

    private func applyBehavior(to panel: NSPanel) {
        let pinned = TermDeskSettings.floatingPinned
        panel.hidesOnDeactivate = !pinned
        panel.isMovableByWindowBackground = !pinned || TermDeskSettings.floatingEdge == "free"
    }

    private func applyEdgeSnap(to panel: NSPanel) {
        guard TermDeskSettings.floatingEdge != "free",
              let screen = NSScreen.main ?? NSScreen.screens.first else { return }

        let visible = screen.visibleFrame
        var frame = panel.frame
        frame.size.width = max(frame.width, 440)
        frame.size.height = max(frame.height, 520)
        frame.origin.y = visible.midY - frame.height / 2

        switch TermDeskSettings.floatingEdge {
        case "left":
            frame.origin.x = visible.minX + 12
        default:
            frame.origin.x = visible.maxX - frame.width - 12
        }

        panel.setFrame(frame, display: true)
    }
}
