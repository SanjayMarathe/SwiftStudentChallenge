import SwiftUI

struct LevelCardView: View {
    let level: LevelData
    let isUnlocked: Bool
    let isCompleted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : isUnlocked ? "play.circle.fill" : "lock.fill")
                    .font(.title2)
                    .foregroundStyle(iconColor)

                Spacer()

                HStack(spacing: 4) {
                    ForEach(0..<level.difficulty.starCount, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(StyleGuide.orange)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(level.title)
                    .font(StyleGuide.headingFont)
                    .foregroundStyle(isUnlocked ? .white : .white.opacity(0.4))

                Text(level.subtitle)
                    .font(StyleGuide.captionFont)
                    .foregroundStyle(isUnlocked ? .white.opacity(0.7) : .white.opacity(0.3))
            }

            Text(level.description)
                .font(StyleGuide.captionFont)
                .foregroundStyle(isUnlocked ? .white.opacity(0.6) : .white.opacity(0.2))
                .lineLimit(2)

            if isUnlocked && !isCompleted {
                Text(level.difficulty.rawValue)
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(StyleGuide.colorForCategory(.structural).opacity(0.3))
                    .clipShape(Capsule())
                    .foregroundStyle(StyleGuide.teal)
            }
        }
        .padding(StyleGuide.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: StyleGuide.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: StyleGuide.cornerRadius)
                .strokeBorder(borderColor, lineWidth: isCompleted ? 2 : 1)
        )
        .opacity(isUnlocked ? 1 : 0.6)
    }

    private var iconColor: Color {
        if isCompleted { return StyleGuide.successGreen }
        if isUnlocked { return StyleGuide.teal }
        return .white.opacity(0.3)
    }

    private var cardBackground: Color {
        isUnlocked ? StyleGuide.surface : StyleGuide.surface.opacity(0.5)
    }

    private var borderColor: Color {
        if isCompleted { return StyleGuide.successGreen.opacity(0.5) }
        if isUnlocked { return StyleGuide.indigo.opacity(0.5) }
        return .white.opacity(0.1)
    }
}
