import SwiftUI

struct CompletionOverlayView: View {
    let isCorrect: Bool
    let level: LevelData
    let rootNodes: [DOMNode]
    let onDismiss: () -> Void
    let onNextLevel: () -> Void

    @State private var showContent = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { if !isCorrect { onDismiss() } }

            cardContent
        }
        .onAppear {
            withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                showContent = true
            }
        }
    }

    private var cardContent: some View {
        VStack(spacing: 20) {
            statusIcon
            statusTitle
            detailSection
            actionButtons
        }
        .padding(30)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.3), radius: 20)
        .scaleEffect(showContent ? 1 : 0.9)
        .padding(40)
    }

    private var statusIcon: some View {
        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
            .font(.system(size: 60))
            .foregroundStyle(isCorrect ? StyleGuide.successGreen : StyleGuide.errorRed)
            .scaleEffect(showContent ? 1 : 0.5)
            .opacity(showContent ? 1 : 0)
    }

    private var statusTitle: some View {
        Text(isCorrect ? "Level Complete!" : "Not Quite Right")
            .font(StyleGuide.titleFont)
            .foregroundStyle(.white)
    }

    @ViewBuilder
    private var detailSection: some View {
        if isCorrect {
            successDetail
        } else {
            hintsDetail
        }
    }

    private var successDetail: some View {
        VStack(spacing: 8) {
            Text("Your Code!")
                .font(StyleGuide.captionFont)
                .foregroundStyle(.white.opacity(0.5))

            ScrollView(.horizontal) {
                Text(rootNodes.map { HTMLCompiler.compile($0) }.joined(separator: "\n"))
                    .font(StyleGuide.codeFont)
                    .foregroundStyle(StyleGuide.teal)
                    .padding(12)
            }
            .background(StyleGuide.background)
            .clipShape(RoundedRectangle(cornerRadius: StyleGuide.smallCornerRadius))
        }
        .frame(maxWidth: 400)
        .opacity(showContent ? 1 : 0)
    }

    private var hintsDetail: some View {
        let hints = DOMComparator.hints(userNode: rootNodes.first, targetNode: level.targetTree)
        return VStack(alignment: .leading, spacing: 4) {
            Text("Hints:")
                .font(StyleGuide.captionFont)
                .foregroundStyle(.white.opacity(0.5))
            ForEach(hints, id: \.self) { hint in
                HintRow(hint: hint)
            }
        }
        .frame(maxWidth: 350, alignment: .leading)
    }

    @ViewBuilder
    private var actionButtons: some View {
        if isCorrect {
            Button("Next Level") { onNextLevel() }
                .buttonStyle(PrimaryButtonStyle(color: StyleGuide.successGreen))
        } else {
            Button("Try Again") { onDismiss() }
                .buttonStyle(PrimaryButtonStyle(color: StyleGuide.indigo))
        }
    }
}

private struct HintRow: View {
    let hint: String
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "lightbulb.fill")
                .font(.caption)
                .foregroundStyle(StyleGuide.orange)
            Text(hint)
                .font(StyleGuide.captionFont)
                .foregroundStyle(.white.opacity(0.8))
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(StyleGuide.bodyFont.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(color.opacity(configuration.isPressed ? 0.7 : 1))
            .clipShape(RoundedRectangle(cornerRadius: StyleGuide.cornerRadius))
    }
}
