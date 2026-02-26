import SwiftUI

struct ContentView: View {
    @State private var appState = AppState()
    @State private var hasLaunched = false

    var body: some View {
        ZStack {
            // Base fill so the purple theme is never exposed to a black ZStack
            StyleGuide.background.ignoresSafeArea()

            if hasLaunched {
                NavigationStack {
                    LevelSelectView(appState: appState)
                        .navigationDestination(for: Int.self) { levelID in
                            if let level = LevelCatalog.levels.first(where: { $0.id == levelID }) {
                                PuzzleView(level: level, appState: appState)
                            }
                        }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .top),
                    removal: .identity
                ))
            } else {
                LandingView {
                    withAnimation(.spring(duration: 0.75, bounce: 0.05)) {
                        hasLaunched = true
                    }
                }
                .transition(.asymmetric(
                    insertion: .identity,
                    removal: .move(edge: .bottom)
                ))
            }
        }
        .preferredColorScheme(.dark)
    }
}
