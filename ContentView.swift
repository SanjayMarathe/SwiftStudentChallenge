import SwiftUI

struct ContentView: View {
    @State private var appState = AppState()

    var body: some View {
        NavigationStack {
            LevelSelectView(appState: appState)
                .navigationDestination(for: Int.self) { levelID in
                    if let level = LevelCatalog.levels.first(where: { $0.id == levelID }) {
                        PuzzleView(level: level, appState: appState)
                    }
                }
        }
        .preferredColorScheme(.dark)
    }
}
