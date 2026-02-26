import SwiftUI

struct PuzzleView: View {
    let level: LevelData
    let appState: AppState

    @State private var puzzleState: PuzzleState
    @Environment(\.dismiss) private var dismiss

    init(level: LevelData, appState: AppState) {
        self.level = level
        self.appState = appState
        self._puzzleState = State(initialValue: PuzzleState(level: level))
    }

    var body: some View {
        ZStack {
            StyleGuide.background.ignoresSafeArea()
            layoutContent
            completionOverlay
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarItems }
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    @ViewBuilder
    private var layoutContent: some View {
        GeometryReader { geo in
            if geo.size.width > geo.size.height {
                landscapeLayout(width: geo.size.width)
            } else {
                portraitLayout
            }
        }
    }

    private func landscapeLayout(width: CGFloat) -> some View {
        HStack(spacing: StyleGuide.padding) {
            leftPanel.frame(width: width * 0.42)
            rightPanel
        }
        .padding(StyleGuide.padding)
    }

    private var portraitLayout: some View {
        ScrollView {
            VStack(spacing: StyleGuide.padding) {
                leftPanel
                rightPanel
            }
            .padding(StyleGuide.padding)
        }
    }

    private var leftPanel: some View {
        VStack(spacing: StyleGuide.padding) {
            TargetView(targetTree: level.targetTree)
            LivePreviewView(rootNodes: puzzleState.rootNodes)
        }
    }

    private var rightPanel: some View {
        VStack(spacing: StyleGuide.padding) {
            BlockPaletteView(availableTags: level.availableTags)
            TreeDisplayView(puzzleState: puzzleState)
            inspectorPanel
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var inspectorPanel: some View {
        if let selectedID = puzzleState.selectedNodeID {
            AttributeInspectorView(puzzleState: puzzleState, nodeID: selectedID)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    @ViewBuilder
    private var completionOverlay: some View {
        if puzzleState.showCompletion {
            CompletionOverlayView(
                isCorrect: puzzleState.isCorrect,
                level: level,
                rootNodes: puzzleState.rootNodes,
                onDismiss: { withAnimation { puzzleState.showCompletion = false } },
                onNextLevel: {
                    appState.completeLevel(level)
                    dismiss()
                }
            )
            .transition(.opacity)
        }
    }

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            PuzzleToolbarTitle(title: level.title, levelID: level.id)
        }
        ToolbarItem(placement: .topBarTrailing) {
            checkButton
        }
        ToolbarItem(placement: .topBarTrailing) {
            resetButton
        }
    }

    private var checkButton: some View {
        Button {
            puzzleState.checkCompletion()
            if puzzleState.isCorrect {
                HapticManager.success()
            } else {
                HapticManager.error()
            }
        } label: {
            Label("Check", systemImage: "checkmark.diamond.fill")
                .font(.system(size: 14, weight: .semibold))
        }
        .tint(StyleGuide.successGreen)
    }

    private var resetButton: some View {
        Button {
            withAnimation(.spring(duration: 0.3)) {
                puzzleState.rootNodes = []
                puzzleState.selectedNodeID = nil
            }
        } label: {
            Label("Reset", systemImage: "arrow.counterclockwise")
                .font(.system(size: 14, weight: .semibold))
        }
        .tint(StyleGuide.orange)
    }
}

private struct PuzzleToolbarTitle: View {
    let title: String
    let levelID: Int
    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(StyleGuide.captionFont)
                .foregroundStyle(.white)
            Text("Level \(levelID)")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}
