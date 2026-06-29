import SwiftUI

enum TermDeskTheme {
    static let panelBackground = Color(red: 0.05, green: 0.06, blue: 0.07)
    static let cardBackground = Color.white.opacity(0.04)
    static let lime = Color(red: 0.72, green: 0.92, blue: 0.38)
    static let rose = Color(red: 0.95, green: 0.45, blue: 0.55)
    static let muted = Color.white.opacity(0.55)
    static let mono = Font.system(.caption, design: .monospaced)
    static let monoSmall = Font.system(.caption2, design: .monospaced)

    static func bracketTitle(_ text: String) -> String {
        "[ \(text) ]"
    }

    static func pressureColor(_ raw: String) -> Color {
        switch raw {
        case "critical": return rose
        case "warning": return Color.orange
        default: return Color(red: 0.45, green: 0.68, blue: 0.95)
        }
    }
}

struct BracketSectionHeader: View {
    let title: String
    let accent: Color

    var body: some View {
        HStack(spacing: 6) {
            Text(TermDeskTheme.bracketTitle(title))
                .font(TermDeskTheme.monoSmall)
                .foregroundStyle(accent)
            Spacer(minLength: 0)
        }
    }
}

struct MetricBar: View {
    let fraction: Double
    let tint: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.08))
                Capsule()
                    .fill(tint.opacity(0.85))
                    .frame(width: max(4, geo.size.width * min(max(fraction, 0), 1)))
            }
        }
        .frame(height: 6)
    }
}

extension View {
    func termDeskPanelFrame(width: CGFloat = 400) -> some View {
        self
            .frame(width: width, alignment: .topLeading)
            .fixedSize(horizontal: true, vertical: true)
    }
}
