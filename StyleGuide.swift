import SwiftUI

enum StyleGuide {
    // MARK: - Colors (Cosmic Code Constructor palette)
    static let indigo = Color(red: 0x3F / 255, green: 0x51 / 255, blue: 0xB5 / 255)       // Planet Blue
    static let teal = Color(red: 0x00 / 255, green: 0xC8 / 255, blue: 0x53 / 255)          // Asteroid Green
    static let orange = Color(red: 0xFF / 255, green: 0x6D / 255, blue: 0x00 / 255)         // Solar Orange
    static let successGreen = Color(red: 0x30 / 255, green: 0xD1 / 255, blue: 0x58 / 255)
    static let errorRed = Color(red: 0xFF / 255, green: 0x3B / 255, blue: 0x30 / 255)
    static let background = Color(red: 0x1A / 255, green: 0x12 / 255, blue: 0x38 / 255)     // Deep Nebula
    static let surface = Color(red: 0x25 / 255, green: 0x1A / 255, blue: 0x45 / 255)
    static let surfaceLight = Color(red: 0x2F / 255, green: 0x21 / 255, blue: 0x55 / 255)

    // New cosmic accents
    static let galacticCyan = Color(red: 0x00 / 255, green: 0xF0 / 255, blue: 0xFF / 255)
    static let plasmaMagenta = Color(red: 0xE1 / 255, green: 0x00 / 255, blue: 0xFF / 255)
    static let starlightWhite = Color(red: 0xF0 / 255, green: 0xF8 / 255, blue: 0xFF / 255)

    static func colorForCategory(_ category: TagCategory) -> Color {
        switch category {
        case .structural: return indigo
        case .typography: return teal
        case .media: return orange
        }
    }

    // MARK: - Fonts
    static let titleFont = Font.system(size: 28, weight: .heavy, design: .rounded)
    static let headingFont = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let bodyFont = Font.system(size: 16, weight: .medium, design: .rounded)
    static let captionFont = Font.system(size: 13, weight: .medium, design: .rounded)
    static let codeFont = Font.system(size: 14, weight: .bold, design: .monospaced)

    // MARK: - Layout
    static let cornerRadius: CGFloat = 25
    static let smallCornerRadius: CGFloat = 12
    static let padding: CGFloat = 16
    static let smallPadding: CGFloat = 8
}

// MARK: - Holo Panel Modifier (frosted glass with gradient border)

struct HoloPanelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: StyleGuide.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: StyleGuide.cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: [StyleGuide.galacticCyan, StyleGuide.plasmaMagenta],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: StyleGuide.galacticCyan.opacity(0.25), radius: 10, x: 0, y: 0)
    }
}

extension View {
    func holoPanelStyle() -> some View {
        modifier(HoloPanelModifier())
    }
}

// MARK: - Tag Glow Modifier (cosmic glow for tag blocks)

struct TagGlowModifier: ViewModifier {
    let color: Color
    let isSelected: Bool

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(isSelected ? 0.6 : 0.3), radius: isSelected ? 8 : 4, x: 0, y: 0)
            .overlay(
                RoundedRectangle(cornerRadius: StyleGuide.smallCornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: [StyleGuide.galacticCyan.opacity(0.4), color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isSelected ? 1.5 : 0.75
                    )
            )
    }
}

extension View {
    func tagGlowStyle(color: Color, isSelected: Bool = false) -> some View {
        modifier(TagGlowModifier(color: color, isSelected: isSelected))
    }
}

// MARK: - Cosmic Background (game screens)

struct CosmicBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.05, green: 0.03, blue: 0.12), location: 0.0),
                    .init(color: StyleGuide.background,                      location: 0.30),
                    .init(color: Color(red: 0.18, green: 0.09, blue: 0.34), location: 0.65),
                    .init(color: Color(red: 0.10, green: 0.05, blue: 0.22), location: 1.0),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            CosmicStarField()
        }
    }
}

private struct CosmicStarField: View {
    @State private var animate = false

    private let stars: [(x: CGFloat, y: CGFloat, size: CGFloat, delay: Double)] = (0..<60).map { i in
        let x = CGFloat((i * 173 + 37) % 100) / 100
        let y = CGFloat((i * 97 + 13) % 100) / 100
        let size = CGFloat((i * 31 + 7) % 4) * 0.4 + 0.5
        let delay = Double(i % 15) * 0.22
        return (x, y, size, delay)
    }

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<stars.count, id: \.self) { i in
                let star = stars[i]
                Circle()
                    .fill(.white)
                    .frame(width: star.size, height: star.size)
                    .position(x: star.x * geo.size.width, y: star.y * geo.size.height)
                    .opacity(animate ? Double((i * 53 + 17) % 10) / 10.0 * 0.55 + 0.1 : 0.04)
                    .animation(
                        .easeInOut(duration: Double((i * 41 + 19) % 15) / 10.0 + 1.2)
                            .repeatForever(autoreverses: true)
                            .delay(star.delay),
                        value: animate
                    )
            }
        }
        .ignoresSafeArea()
        .onAppear { animate = true }
    }
}
