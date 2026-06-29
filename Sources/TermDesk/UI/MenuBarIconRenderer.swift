import AppKit
import TermDeskShared

enum MenuBarIconRenderer {
    private static let canvas = NSSize(width: 18, height: 18)

    static func makeImage(sys: SysSection?) -> NSImage {
        let image = NSImage(size: canvas)
        image.lockFocus()

        let bracket = NSBezierPath()
        bracket.move(to: NSPoint(x: 3, y: 4))
        bracket.line(to: NSPoint(x: 3, y: 14))
        bracket.move(to: NSPoint(x: 15, y: 4))
        bracket.line(to: NSPoint(x: 15, y: 14))
        NSColor.labelColor.withAlphaComponent(0.55).setStroke()
        bracket.lineWidth = 1.2
        bracket.stroke()

        let pLoad = clamp((sys?.pCoreLoad ?? 0) / 100)
        let eLoad = clamp((sys?.eCoreLoad ?? 0) / 100)
        drawBars(loads: [pLoad, eLoad], in: NSRect(x: 5.5, y: 4.5, width: 7, height: 9))

        let prompt = NSBezierPath()
        prompt.move(to: NSPoint(x: 6, y: 6.5))
        prompt.line(to: NSPoint(x: 8.5, y: 6.5))
        prompt.line(to: NSPoint(x: 8.5, y: 11))
        NSColor.labelColor.withAlphaComponent(0.85).setStroke()
        prompt.lineWidth = 1
        prompt.stroke()

        image.unlockFocus()
        image.isTemplate = true
        return image
    }

    private static func drawBars(loads: [Double], in rect: NSRect) {
        let gap: CGFloat = 1
        let barWidth = (rect.width - gap * CGFloat(loads.count - 1)) / CGFloat(loads.count)
        for (index, load) in loads.enumerated() {
            let x = rect.minX + CGFloat(index) * (barWidth + gap)
            let barRect = NSRect(x: x, y: rect.minY, width: barWidth, height: rect.height)
            NSColor.labelColor.withAlphaComponent(0.12).setFill()
            NSBezierPath(roundedRect: barRect, xRadius: 0.8, yRadius: 0.8).fill()
            let fillH = max(1, barRect.height * load)
            let fillRect = NSRect(x: barRect.minX, y: barRect.minY, width: barRect.width, height: fillH)
            NSColor.labelColor.withAlphaComponent(0.75).setFill()
            NSBezierPath(roundedRect: fillRect, xRadius: 0.8, yRadius: 0.8).fill()
        }
    }

    private static func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }
}
