import SwiftUI

struct TagBlockView: View {
    let tagType: TagType
    var isDraggable: Bool = true
    var isSelected: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        tagLabel
            .contentShape(RoundedRectangle(cornerRadius: StyleGuide.smallCornerRadius))
            .onTapGesture { onTap?() }
            .draggable(isDraggable ? tagType.rawValue : "")
            .accessibilityLabel("\(tagType.displayName) tag block")
    }

    private var tagLabel: some View {
        let color = StyleGuide.colorForCategory(tagType.category)
        return HStack(spacing: 6) {
            Image(systemName: tagType.sfSymbol)
                .font(.system(size: 12, weight: .semibold))
            Text(tagType.displayName)
                .font(StyleGuide.codeFont)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(isSelected ? 0.4 : 0.2))
        .foregroundStyle(color)
        .clipShape(RoundedRectangle(cornerRadius: StyleGuide.smallCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: StyleGuide.smallCornerRadius)
                .strokeBorder(color.opacity(isSelected ? 0.8 : 0.4), lineWidth: isSelected ? 2 : 1)
        )
    }
}
