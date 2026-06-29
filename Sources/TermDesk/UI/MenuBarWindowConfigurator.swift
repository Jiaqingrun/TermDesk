import AppKit
import SwiftUI

struct MenuBarWindowConfigurator: NSViewRepresentable {
    var contentSize: CGSize

    func makeNSView(context: Context) -> ConfiguratorView {
        ConfiguratorView()
    }

    func updateNSView(_ nsView: ConfiguratorView, context: Context) {
        nsView.apply(contentSize: contentSize)
    }

    final class ConfiguratorView: NSView {
        private var configuredWindows = Set<ObjectIdentifier>()
        private var lastContentSize: CGSize = .zero

        func apply(contentSize: CGSize) {
            guard let window else { return }

            let windowID = ObjectIdentifier(window)
            if !configuredWindows.contains(windowID) {
                window.titleVisibility = .hidden
                window.titlebarAppearsTransparent = true
                window.styleMask.insert(.fullSizeContentView)
                window.isMovableByWindowBackground = true
                window.backgroundColor = .clear
                window.hasShadow = true
                configuredWindows.insert(windowID)
            }

            guard contentSize.width > 0, contentSize.height > 0 else { return }

            let target = NSSize(width: ceil(contentSize.width), height: ceil(contentSize.height))
            if abs(lastContentSize.width - target.width) > 1 || abs(lastContentSize.height - target.height) > 1 {
                let current = window.contentView?.bounds.size ?? .zero
                if abs(current.width - target.width) > 1 || abs(current.height - target.height) > 1 {
                    window.setContentSize(target)
                }
                lastContentSize = target
            }
        }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            apply(contentSize: lastContentSize)
        }
    }
}

private struct PanelContentSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let next = nextValue()
        if next.height > value.height || next.width > value.width {
            value = next
        }
    }
}

extension View {
    func menuBarPanelFrame(width: CGFloat) -> some View {
        modifier(MenuBarPanelFrameModifier(width: width))
    }
}

private struct MenuBarPanelFrameModifier: ViewModifier {
    let width: CGFloat
    @State private var contentSize: CGSize = .zero

    func body(content: Content) -> some View {
        content
            .frame(width: width, alignment: .topLeading)
            .fixedSize(horizontal: true, vertical: true)
            .background {
                GeometryReader { proxy in
                    Color.clear.preference(key: PanelContentSizeKey.self, value: proxy.size)
                }
            }
            .onPreferenceChange(PanelContentSizeKey.self) { size in
                guard abs(size.width - contentSize.width) > 1 || abs(size.height - contentSize.height) > 1 else { return }
                contentSize = size
            }
            .background {
                MenuBarWindowConfigurator(contentSize: contentSize)
                    .frame(width: 0, height: 0)
            }
    }
}
