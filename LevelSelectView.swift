import SwiftUI

struct LevelSelectView: View {
    let appState: AppState
    @State private var animateGradient = false
    @State private var cardsAppeared = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                levelCards
            }
            .padding(.horizontal, StyleGuide.padding)
            .padding(.bottom, 40)
        }
        .background { CosmicBackground() }
        .navigationTitle("")
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { cardsAppeared = true }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { animateGradient = true }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.system(size: 44))
                .foregroundStyle(
                    LinearGradient(
                        colors: [StyleGuide.indigo, StyleGuide.teal],
                        startPoint: animateGradient ? .topLeading : .bottomLeading,
                        endPoint: animateGradient ? .bottomTrailing : .topTrailing
                    )
                )
                .accessibilityLabel("Cosmic Code Constructor logo")

            Text("Cosmic Code Constructor")
                .font(StyleGuide.titleFont)
                .foregroundStyle(.white)

            Text("Build the web, block by block")
                .font(StyleGuide.bodyFont)
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
    }

    private var levelCards: some View {
        ForEach(LevelCatalog.levels) { level in
            LevelCardRow(level: level, appState: appState)
        }
        .offset(y: cardsAppeared ? 0 : 20)
        .opacity(cardsAppeared ? 1 : 0)
    }
}

private struct LevelCardRow: View {
    let level: LevelData
    let appState: AppState

    var body: some View {
        let unlocked = appState.isUnlocked(level)
        let completed = appState.isCompleted(level)

        Group {
            if unlocked {
                NavigationLink(value: level.id) {
                    LevelCardView(level: level, isUnlocked: true, isCompleted: completed)
                }
                .buttonStyle(.plain)
            } else {
                LevelCardView(level: level, isUnlocked: false, isCompleted: false)
            }
        }
        .accessibilityLabel("Level \(level.id): \(level.title)")
    }
}
