import UIKit

@MainActor
enum HapticManager {
    private static let notificationGenerator = UINotificationFeedbackGenerator()
    private static let impactGenerator = UIImpactFeedbackGenerator(style: .medium)

    static func success() {
        notificationGenerator.notificationOccurred(.success)
    }

    static func error() {
        notificationGenerator.notificationOccurred(.error)
    }

    static func impact() {
        impactGenerator.impactOccurred()
    }
}
