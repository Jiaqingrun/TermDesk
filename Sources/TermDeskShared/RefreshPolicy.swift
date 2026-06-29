import Foundation

/// 面板开闭自适应采样间隔（对齐 SysPeek RefreshPolicy）。
public enum TermDeskRefreshPolicy {
    public static let iconOnlyInterval: TimeInterval = 8
    public static let panelRefreshInterval: TimeInterval = 0.5
    public static let qrRefreshInterval: TimeInterval = 30
    public static let widgetStaleThreshold: TimeInterval = 12

    public static func interval(panelOpen: Bool) -> TimeInterval {
        panelOpen ? panelRefreshInterval : iconOnlyInterval
    }
}
