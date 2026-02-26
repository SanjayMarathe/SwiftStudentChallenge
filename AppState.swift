import SwiftUI

@MainActor
@Observable
final class AppState {
    var completedLevelIDs: Set<Int> = []

    func isUnlocked(_ level: LevelData) -> Bool {
        if level.id == 1 { return true }
        return completedLevelIDs.contains(level.id - 1)
    }

    func completeLevel(_ level: LevelData) {
        completedLevelIDs.insert(level.id)
    }

    func isCompleted(_ level: LevelData) -> Bool {
        completedLevelIDs.contains(level.id)
    }
}
