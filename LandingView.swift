import SwiftUI

struct LandingView: View {
    let onLaunch: () -> Void

    @State private var titleAppeared = false
    @State private var cardsAppeared = false
    @State private var stepsAppeared = false
    @State private var buttonAppeared = false
    @State private var pulseGlow = false

    var body: some View {
        ZStack {
            spaceBackground
            LandingStarField()

            ScrollView {
                VStack(spacing: 0) {
                    heroSection
                        .padding(.bottom, 44)

                    featureCards
                        .padding(.bottom, 44)

                    howItWorks
                        .padding(.bottom, 52)

                    launchButton
                        .padding(.bottom, 60)
                }
                .padding(.horizontal, 28)
                .padding(.top, 64)
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) { titleAppeared = true }
            withAnimation(.easeOut(duration: 0.7).delay(0.35)) { cardsAppeared = true }
            withAnimation(.easeOut(duration: 0.7).delay(0.65)) { stepsAppeared = true }
            withAnimation(.easeOut(duration: 0.7).delay(0.9)) { buttonAppeared = true }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                pulseGlow = true
            }
        }
    }

    // MARK: - Background

    private var spaceBackground: some View {
        ZStack {
            // Deep space to sun gradient
            LinearGradient(
                stops: [
                    .init(color: .black, location: 0.0),
                    .init(color: Color(red: 0.04, green: 0.02, blue: 0.07), location: 0.30),
                    .init(color: Color(red: 0.12, green: 0.06, blue: 0.01), location: 0.58),
                    .init(color: Color(red: 0.38, green: 0.16, blue: 0.00), location: 0.78),
                    .init(color: Color(red: 0.72, green: 0.38, blue: 0.00), location: 0.92),
                    .init(color: Color(red: 1.00, green: 0.68, blue: 0.10), location: 1.0),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Sun corona bleeding up from the bottom edge
            GeometryReader { geo in
                RadialGradient(
                    colors: [
                        Color(red: 1.00, green: 0.90, blue: 0.35).opacity(0.85),
                        Color(red: 1.00, green: 0.60, blue: 0.05).opacity(0.45),
                        Color(red: 0.90, green: 0.30, blue: 0.00).opacity(0.15),
                        .clear,
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: geo.size.width * 0.55
                )
                .frame(width: geo.size.width * 1.1, height: geo.size.width * 1.1)
                .blur(radius: 20)
                .position(x: geo.size.width / 2, y: geo.size.height + geo.size.width * 0.12)
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(StyleGuide.galacticCyan.opacity(pulseGlow ? 0.20 : 0.07))
                    .frame(width: 150, height: 150)
                    .blur(radius: pulseGlow ? 28 : 16)

                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [StyleGuide.galacticCyan, StyleGuide.plasmaMagenta],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 4) {
                Text("Cosmic Code")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(StyleGuide.starlightWhite)

                Text("Constructor")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(StyleGuide.starlightWhite)
            }
            .multilineTextAlignment(.center)

            Text("Build real websites using colourful space blocks!")
                .font(StyleGuide.bodyFont)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .opacity(titleAppeared ? 1 : 0)
    }

    // MARK: - Feature Cards

    private var featureCards: some View {
        VStack(spacing: 14) {
            LandingFeatureCard(
                icon: "square.stack.3d.up.fill",
                iconColor: StyleGuide.indigo,
                title: "Build With Blocks",
                description: "Grab colourful blocks from the palette and snap them together to build a real webpage — no typing needed!"
            )
            LandingFeatureCard(
                icon: "globe.europe.africa.fill",
                iconColor: StyleGuide.galacticCyan,
                title: "See It Come Alive",
                description: "Watch your creation appear as a glowing 3D space station that you can spin around and explore!"
            )
            LandingFeatureCard(
                icon: "trophy.fill",
                iconColor: StyleGuide.orange,
                title: "Complete Missions",
                description: "Match the Goal on each level to unlock bigger, tougher challenges and become a web wizard!"
            )
        }
        .opacity(cardsAppeared ? 1 : 0)
    }

    // MARK: - How It Works

    private var howItWorks: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How to Play")
                .font(StyleGuide.headingFont)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 14) {
                LandingStepRow(number: "1", text: "Look at the Goal — that's what you need to build")
                LandingStepRow(number: "2", text: "Drag blocks from Building Blocks onto Your Build")
                LandingStepRow(number: "3", text: "Tap Check when you're done — see how you did!")
            }
        }
        .padding(StyleGuide.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .holoPanelStyle()
        .opacity(stepsAppeared ? 1 : 0)
    }

    // MARK: - Launch Button

    private var launchButton: some View {
        Button(action: onLaunch) {
            HStack(spacing: 12) {
                Image(systemName: "rocket.fill")
                    .font(.system(size: 22, weight: .bold))
                Text("Launch!")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
            }
            .foregroundStyle(.black)
            .padding(.horizontal, 52)
            .padding(.vertical, 20)
            .background(
                LinearGradient(
                    colors: [StyleGuide.galacticCyan, StyleGuide.plasmaMagenta.opacity(0.85)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .shadow(
                color: StyleGuide.galacticCyan.opacity(pulseGlow ? 0.75 : 0.3),
                radius: pulseGlow ? 22 : 10,
                x: 0, y: 0
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(buttonAppeared ? 1 : 0.85)
        .opacity(buttonAppeared ? 1 : 0)
    }
}

// MARK: - Feature Card

private struct LandingFeatureCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.18))
                    .frame(width: 52, height: 52)
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(StyleGuide.headingFont)
                    .foregroundStyle(.white)
                Text(description)
                    .font(StyleGuide.captionFont)
                    .foregroundStyle(.white.opacity(0.65))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(StyleGuide.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .holoPanelStyle()
    }
}

// MARK: - Step Row

private struct LandingStepRow: View {
    let number: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(StyleGuide.galacticCyan.opacity(0.2))
                    .frame(width: 30, height: 30)
                Text(number)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(StyleGuide.galacticCyan)
            }
            Text(text)
                .font(StyleGuide.captionFont)
                .foregroundStyle(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Star Field
// Stars are concentrated in the upper 70% of the screen so they
// fade naturally into the sun glow below.

private struct LandingStarField: View {
    @State private var animate = false

    private let stars: [(x: CGFloat, y: CGFloat, size: CGFloat, delay: Double)] = (0..<55).map { i in
        let x = CGFloat((i * 173 + 37) % 100) / 100
        let y = CGFloat((i * 97 + 13) % 70) / 100   // top 70% only
        let size = CGFloat((i * 31 + 7) % 4) * 0.45 + 0.5
        let delay = Double(i % 14) * 0.25
        return (x, y, size, delay)
    }

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<stars.count, id: \.self) { i in
                let star = stars[i]
                Circle()
                    .fill(.white)
                    .frame(width: star.size, height: star.size)
                    .position(
                        x: star.x * geo.size.width,
                        y: star.y * geo.size.height
                    )
                    .opacity(
                        animate
                            ? Double((i * 53 + 17) % 10) / 10.0 * 0.65 + 0.15
                            : 0.04
                    )
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
