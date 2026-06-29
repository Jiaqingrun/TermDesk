import AppKit
import Foundation
import ServiceManagement

enum LoginItemManager {
    enum Status {
        case enabled
        case requiresApproval
        case notRegistered
        case notFound

        var label: String {
            switch self {
            case .enabled: return "已启用"
            case .requiresApproval: return "需在系统设置中批准"
            case .notRegistered: return "未注册"
            case .notFound: return "未找到"
            }
        }
    }

    static var status: Status {
        switch SMAppService.mainApp.status {
        case .enabled: return .enabled
        case .requiresApproval: return .requiresApproval
        case .notRegistered: return .notRegistered
        case .notFound: return .notFound
        @unknown default: return .notFound
        }
    }

    static var isEnabled: Bool {
        status == .enabled
    }

    static func setEnabled(_ enabled: Bool) throws {
        if enabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
    }

    static func openSystemSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension") {
            NSWorkspace.shared.open(url)
        }
    }
}
