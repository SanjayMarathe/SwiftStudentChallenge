import SwiftUI

struct BlockPaletteView: View {
    let availableTags: [TagType]

    private var groupedTags: [(TagCategory, [TagType])] {
        let categories: [TagCategory] = [.structural, .typography, .media]
        return categories.compactMap { cat in
            let tags = availableTags.filter { $0.category == cat }
            return tags.isEmpty ? nil : (cat, tags)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Building Blocks", systemImage: "tray.full.fill")
                .font(StyleGuide.captionFont)
                .foregroundStyle(.white.opacity(0.5))

            ForEach(groupedTags, id: \.0.rawValue) { category, tags in
                VStack(alignment: .leading, spacing: 6) {
                    Text(category.rawValue)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(StyleGuide.colorForCategory(category).opacity(0.7))
                        .textCase(.uppercase)

                    FlowLayout(spacing: 6) {
                        ForEach(tags, id: \.rawValue) { tag in
                            TagBlockView(tagType: tag)
                        }
                    }
                }
            }
        }
        .padding(StyleGuide.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .holoPanelStyle()
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}
