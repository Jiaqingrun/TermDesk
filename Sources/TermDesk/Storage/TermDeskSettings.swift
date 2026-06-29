import Foundation

enum TermDeskSettings {
    private static let defaults = UserDefaults.standard

    /// 为 true 时菜单栏点击只弹出菜单，完整面板走悬浮窗。
    static var menuBarCompact: Bool {
        get { defaults.bool(forKey: "termdesk.menuBarCompact") }
        set { defaults.set(newValue, forKey: "termdesk.menuBarCompact") }
    }

    /// 为 true 且 SysPeek 快照过期时，不自行采样（避免双份 Mach 开销）。
    static var preferSysPeekSnapshot: Bool {
        get {
            if defaults.object(forKey: "termdesk.preferSysPeek") == nil { return true }
            return defaults.bool(forKey: "termdesk.preferSysPeek")
        }
        set { defaults.set(newValue, forKey: "termdesk.preferSysPeek") }
    }

    /// 悬浮窗贴边：free / right / left
    static var floatingEdge: String {
        get { defaults.string(forKey: "termdesk.floatingEdge") ?? "right" }
        set { defaults.set(newValue, forKey: "termdesk.floatingEdge") }
    }

    /// 钉住后关闭时仅隐藏，保持位置；且不在失焦时自动隐藏。
    static var floatingPinned: Bool {
        get { defaults.bool(forKey: "termdesk.floatingPinned") }
        set { defaults.set(newValue, forKey: "termdesk.floatingPinned") }
    }
}
