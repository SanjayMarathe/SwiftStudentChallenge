import SwiftUI

@MainActor
enum DOMRenderer {
    static func render(_ node: DOMNode) -> AnyView {
        switch node.tagType.category {
        case .structural:
            return renderStructural(node)
        case .typography:
            return renderTypography(node)
        case .media:
            return renderMedia(node)
        }
    }

    private static func renderStructural(_ node: DOMNode) -> AnyView {
        let pad = domPadding(node)
        switch node.tagType {
        case .nav:
            return AnyView(
                HStack(spacing: 12) {
                    renderChildrenGroup(node)
                }
                .padding(pad)
            )
        case .footer:
            return AnyView(
                VStack(alignment: .leading, spacing: 4) {
                    renderChildrenGroup(node)
                }
                .padding(.top, 4)
                .foregroundStyle(.secondary)
                .padding(pad)
            )
        default:
            return AnyView(
                VStack(alignment: .leading, spacing: 8) {
                    renderChildrenGroup(node)
                }
                .padding(pad)
            )
        }
    }

    private static func renderTypography(_ node: DOMNode) -> AnyView {
        let size = fontSize(node)
        let color = textColor(node)
        let pad = domPadding(node)

        switch node.tagType {
        case .h1:
            return AnyView(
                Text(node.textContent ?? "Heading 1")
                    .font(.system(size: size ?? 28, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                    .padding(pad)
            )
        case .h2:
            return AnyView(
                Text(node.textContent ?? "Heading 2")
                    .font(.system(size: size ?? 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(color)
                    .padding(pad)
            )
        case .h3:
            return AnyView(
                Text(node.textContent ?? "Heading 3")
                    .font(.system(size: size ?? 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(color)
                    .padding(pad)
            )
        case .a:
            return AnyView(
                Text(node.textContent ?? "Link")
                    .font(.system(size: size ?? 16, design: .rounded))
                    .foregroundStyle(StyleGuide.teal)
                    .underline()
                    .padding(pad)
            )
        default:
            return AnyView(
                Text(node.textContent ?? (node.tagType == .span ? "span" : "Paragraph text"))
                    .font(.system(size: size ?? 16, design: .rounded))
                    .foregroundStyle(color)
                    .padding(pad)
            )
        }
    }

    private static func renderMedia(_ node: DOMNode) -> AnyView {
        let altText = node.attributes["alt"]
        let pad = domPadding(node)
        return AnyView(
            RoundedRectangle(cornerRadius: 8)
                .fill(StyleGuide.surface)
                .frame(width: 80, height: 80)
                .overlay(
                    ImagePlaceholder(altText: altText)
                )
                .padding(pad)
        )
    }

    @ViewBuilder
    static func renderChildrenGroup(_ node: DOMNode) -> some View {
        if let text = node.textContent {
            Text(text)
                .font(StyleGuide.bodyFont)
                .foregroundStyle(.white)
        }
        ForEach(node.children) { child in
            render(child)
        }
    }

    private static func domPadding(_ node: DOMNode) -> CGFloat {
        node.attributes["padding"].flatMap { Double($0) }.map { CGFloat($0) } ?? 0
    }

    private static func fontSize(_ node: DOMNode) -> CGFloat? {
        guard let sizeStr = node.attributes["font-size"],
              let size = Double(sizeStr) else { return nil }
        return CGFloat(size)
    }

    private static func textColor(_ node: DOMNode) -> Color {
        guard let colorStr = node.attributes["color"] else { return .white }
        return colorFromString(colorStr)
    }

    static func colorFromString(_ str: String) -> Color {
        switch str.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "yellow": return .yellow
        case "white": return .white
        case "indigo": return StyleGuide.indigo
        case "teal": return StyleGuide.teal
        default: return .white
        }
    }
}

private struct ImagePlaceholder: View {
    let altText: String?
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "photo")
                .font(.title2)
            if let alt = altText {
                Text(alt)
                    .font(.caption2)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(.white.opacity(0.5))
    }
}
