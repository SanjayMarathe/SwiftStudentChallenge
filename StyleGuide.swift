import SwiftUI

enum StyleGuide {
    // MARK: - Colors
    static let indigo = Color(red: 0x5E / 255, green: 0x5C / 255, blue: 0xE6 / 255)
    static let teal = Color(red: 0x5A / 255, green: 0xC8 / 255, blue: 0xFA / 255)
    static let orange = Color(red: 0xFF / 255, green: 0x95 / 255, blue: 0x00 / 255)
    static let successGreen = Color(red: 0x30 / 255, green: 0xD1 / 255, blue: 0x58 / 255)
    static let errorRed = Color(red: 0xFF / 255, green: 0x3B / 255, blue: 0x30 / 255)
    static let background = Color(red: 0x1C / 255, green: 0x1C / 255, blue: 0x1E / 255)
    static let surface = Color(red: 0x2C / 255, green: 0x2C / 255, blue: 0x2E / 255)
    static let surfaceLight = Color(red: 0x3A / 255, green: 0x3A / 255, blue: 0x3C / 255)

    static func colorForCategory(_ category: TagCategory) -> Color {
        switch category {
        case .structural: return indigo
        case .typography: return teal
        case .media: return orange
        }
    }

    // MARK: - Fonts
    static let titleFont = Font.system(size: 28, weight: .bold, design: .rounded)
    static let headingFont = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let bodyFont = Font.system(size: 16, weight: .regular, design: .rounded)
    static let captionFont = Font.system(size: 13, weight: .medium, design: .rounded)
    static let codeFont = Font.system(size: 14, weight: .medium, design: .monospaced)

    // MARK: - Layout
    static let cornerRadius: CGFloat = 12
    static let smallCornerRadius: CGFloat = 8
    static let padding: CGFloat = 16
    static let smallPadding: CGFloat = 8
}