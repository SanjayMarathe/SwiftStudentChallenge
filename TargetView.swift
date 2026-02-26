import SwiftUI

struct TargetView: View {
    let targetTree: DOMNode

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Target", systemImage: "target")
                .font(StyleGuide.captionFont)
                .foregroundStyle(.white.opacity(0.5))

            DOMRenderer.render(targetTree)
                .padding(StyleGuide.padding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: StyleGuide.smallCornerRadius))
        }
        .padding(StyleGuide.padding)
        .background(StyleGuide.surface)
        .clipShape(RoundedRectangle(cornerRadius: StyleGuide.cornerRadius))
    }
}
