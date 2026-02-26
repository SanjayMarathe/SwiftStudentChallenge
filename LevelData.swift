import Foundation

struct LevelData: Identifiable, Sendable {
    let id: Int
    let title: String
    let subtitle: String
    let description: String
    let difficulty: Difficulty
    let targetTree: DOMNode
    let availableTags: [TagType]

    enum Difficulty: String, Sendable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"

        var starCount: Int {
            switch self {
            case .beginner: return 1
            case .intermediate: return 2
            case .advanced: return 3
            }
        }
    }
}
