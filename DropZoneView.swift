import SwiftUI

struct DropZoneView: View {
    let label: String
    var compact: Bool = false

    var body: some View {
        HStack {
            Image(systemName: "plus.circle.dashed")
                .font(compact ? .caption : .body)
            Text(label)
                .font(compact ? .caption2 : StyleGuide.captionFont)
        }
        .foregroundStyle(.white.opacity(0.25))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(compact ? 6 : 12)
        .background(
            RoundedRectangle(cornerRadius: StyleGuide.smallCornerRadius)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
                .foregroundStyle(.white.opacity(0.15))
        )
        .accessibilityLabel(label)
    }
}
