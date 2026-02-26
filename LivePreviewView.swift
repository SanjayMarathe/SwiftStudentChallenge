import SwiftUI

struct LivePreviewView: View {
    let rootNodes: [DOMNode]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Live Preview", systemImage: "eye.fill")
                .font(StyleGuide.captionFont)
                .foregroundStyle(.white.opacity(0.5))

            if rootNodes.isEmpty {
                Text("Start building to see a preview")
                    .font(StyleGuide.captionFont)
                    .foregroundStyle(.white.opacity(0.3))
                    .frame(maxWidth: .infinity, minHeight: 80)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(rootNodes) { node in
                        DOMRenderer.render(node)
                    }
                }
                .padding(StyleGuide.padding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: StyleGuide.smallCornerRadius))
            }
        }
        .padding(StyleGuide.padding)
        .background(StyleGuide.surface)
        .clipShape(RoundedRectangle(cornerRadius: StyleGuide.cornerRadius))
    }
}
