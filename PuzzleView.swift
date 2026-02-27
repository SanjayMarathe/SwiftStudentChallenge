import SwiftUI

struct PuzzleView: View {
    let level: LevelData
    let appState: AppState

    @State private var puzzleState: PuzzleState
    @State private var show3DPreview = false
    @State private var showImmersive = false
    @Environment(\.dismiss) private var dismiss

    init(level: LevelData, appState: AppState) {
        self.level = level
        self.appState = appState
        self._puzzleState = State(initialValue: PuzzleState(level: level))
    }

    var body: some View {
        ZStack {
            CosmicBackground()
            layoutContent
            completionOverlay
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarItems }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .fullScreenCover(isPresented: $showImmersive) {
            NavigationStack {
                ImmersiveView(level: level, appState: appState, puzzleState: puzzleState)
            }
        }
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
            leftPanel.frame(width: width * 0.50)
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
            previewPicker
            if show3DPreview {
                DOMSceneView(
                    rootNodes: puzzleState.rootNodes,
                    selectedNodeID: puzzleState.selectedNodeID
                )
            } else {
                LivePreviewView(rootNodes: puzzleState.rootNodes)
            }
        }
    }

    private var previewPicker: some View {
        Picker("Preview Mode", selection: $show3DPreview) {
            Text("2D").tag(false)
            Text("3D").tag(true)
        }
        .pickerStyle(.segmented)
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
            Button { showImmersive = true } label: {
                Label("Immersive", systemImage: "camera.viewfinder")
                    .font(.system(size: 14, weight: .semibold))
            }
            .tint(StyleGuide.galacticCyan)
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

// MARK: - ImmersiveView

private struct TagFrameKey: PreferenceKey {
    typealias Value = [TagType: CGRect]
    nonisolated(unsafe) static var defaultValue = Value()
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { _, new in new }
    }
}

private struct DropZoneFrameKey: PreferenceKey {
    typealias Value = CGRect
    nonisolated(unsafe) static var defaultValue = CGRect.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        let next = nextValue()
        if next != .zero { value = next }
    }
}

private struct NodeFrameKey: PreferenceKey {
    typealias Value = [UUID: CGRect]
    nonisolated(unsafe) static var defaultValue = Value()
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { _, new in new }
    }
}

@MainActor
struct ImmersiveView: View {
    let level: LevelData
    let appState: AppState
    let puzzleState: PuzzleState

    @State private var tracking = HandTrackingManager()
    @State private var grabbedTag: TagType? = nil
    @State private var tileFrames: [TagType: CGRect] = [:]
    @State private var dropZoneFrame: CGRect = .zero
    @State private var containerFrames: [UUID: CGRect] = [:]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geo in
            ZStack {
                CameraFeedView(session: tracking.session).ignoresSafeArea()
                StyleGuide.background.opacity(0.40).ignoresSafeArea()
                contentLayer
                floatingBlockLayer
                handCursorLayer
                completionLayer
                if tracking.cameraPermissionDenied {
                    cameraPermissionOverlay
                }
            }
            .coordinateSpace(name: "immersive")
            .onAppear {
                tracking.viewSize = geo.size
                tracking.start()
            }
            .onChange(of: geo.size) { _, s in tracking.viewSize = s }
            .onDisappear { tracking.stop() }
            .onChange(of: tracking.isPinching) { _, new in handlePinch(became: new) }
            .onPreferenceChange(TagFrameKey.self)    { tileFrames = $0 }
            .onPreferenceChange(DropZoneFrameKey.self) { dropZoneFrame = $0 }
            .onPreferenceChange(NodeFrameKey.self)   { containerFrames = $0 }
        }
        .ignoresSafeArea()
        .navigationTitle("Immersive Mode")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar { immersiveToolbar }
    }

    private var contentLayer: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: StyleGuide.padding) {
                Spacer()
                nodeCountPanel
            }
            .padding(.horizontal, StyleGuide.padding)
            .padding(.top, StyleGuide.padding)
            Spacer()
            dropZonePanel
            Spacer()
            blockPalette.padding(.bottom, StyleGuide.padding)
        }
    }

    private var nodeCountPanel: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("Placed").font(.caption2).foregroundStyle(.white.opacity(0.5))
            Text("\(puzzleState.rootNodes.count)")
                .font(StyleGuide.titleFont).foregroundStyle(StyleGuide.galacticCyan)
            ForEach(puzzleState.rootNodes) { node in
                Text(node.tagType.displayName)
                    .font(StyleGuide.codeFont).foregroundStyle(StyleGuide.teal)
            }
        }
        .padding(StyleGuide.smallPadding)
        .holoPanelStyle()
    }

    private var dropZonePanel: some View {
        VStack(spacing: 8) {
            Label("Drop Zone", systemImage: "arrow.down.to.line")
                .font(StyleGuide.captionFont).foregroundStyle(.white.opacity(0.6))
            dropZoneContent
                .background(GeometryReader { proxy in
                    Color.clear.preference(key: DropZoneFrameKey.self,
                                           value: proxy.frame(in: .named("immersive")))
                })
        }
    }

    @ViewBuilder
    private var dropZoneContent: some View {
        if puzzleState.rootNodes.isEmpty {
            Text("Pinch a block here")
                .font(StyleGuide.captionFont)
                .foregroundStyle(.white.opacity(0.35))
                .frame(width: 300, height: 140)
        } else {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(puzzleState.rootNodes) { node in
                        ImmersiveBlockNode(node: node)
                    }
                }
                .padding(12)
            }
            .frame(width: 300)
            .frame(maxHeight: 240)
            .holoPanelStyle()
        }
    }

    private var blockPalette: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(level.availableTags, id: \.self) { tag in
                    immersiveTile(tag: tag)
                        .opacity(grabbedTag == tag ? 0.35 : 1.0)
                        .scaleEffect(grabbedTag == tag ? 0.9 : 1.0)
                        .animation(.spring(duration: 0.2), value: grabbedTag == tag)
                        .background(GeometryReader { proxy in
                            Color.clear.preference(key: TagFrameKey.self,
                                                   value: [tag: proxy.frame(in: .named("immersive"))])
                        })
                }
            }
            .padding(.horizontal, StyleGuide.padding)
            .padding(.vertical, StyleGuide.smallPadding)
        }
        .padding(.horizontal, StyleGuide.padding)
    }

    @ViewBuilder private var floatingBlockLayer: some View {
        if let tag = grabbedTag, let point = tracking.pinchPoint {
            immersiveTile(tag: tag)
                .scaleEffect(1.15)
                .shadow(color: StyleGuide.galacticCyan.opacity(0.7), radius: 20)
                .position(point)
                .allowsHitTesting(false)
        }
    }

    @ViewBuilder private var handCursorLayer: some View {
        if tracking.handVisible, let point = tracking.pinchPoint {
            handCursor.position(point).allowsHitTesting(false)
        }
    }

    private var handCursor: some View {
        let sz: CGFloat = tracking.isPinching ? 20 : 30
        return ZStack {
            Circle().fill(StyleGuide.galacticCyan.opacity(tracking.isPinching ? 0.45 : 0.2))
                .frame(width: sz, height: sz)
            Circle().strokeBorder(StyleGuide.galacticCyan, lineWidth: 1.5)
                .frame(width: sz, height: sz)
        }
        .shadow(color: StyleGuide.galacticCyan.opacity(0.8), radius: tracking.isPinching ? 6 : 12)
        .animation(.easeOut(duration: 0.08), value: tracking.isPinching)
    }

    @ViewBuilder private var completionLayer: some View {
        if puzzleState.showCompletion {
            CompletionOverlayView(
                isCorrect: puzzleState.isCorrect, level: level,
                rootNodes: puzzleState.rootNodes,
                onDismiss: { withAnimation { puzzleState.showCompletion = false } },
                onNextLevel: { appState.completeLevel(level); dismiss() }
            ).transition(.opacity)
        }
    }

    @ToolbarContentBuilder private var immersiveToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                puzzleState.checkCompletion()
                puzzleState.isCorrect ? HapticManager.success() : HapticManager.error()
            } label: {
                Label("Check", systemImage: "checkmark.diamond.fill")
                    .font(.system(size: 14, weight: .semibold))
            }.tint(StyleGuide.successGreen)
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button { dismiss() } label: {
                Label("2D View", systemImage: "rectangle.on.rectangle")
                    .font(.system(size: 14, weight: .semibold))
            }.tint(StyleGuide.galacticCyan)
        }
    }

    private func immersiveTile(tag: TagType) -> some View {
        let color = StyleGuide.colorForCategory(tag.category)
        let r: CGFloat = 14
        return VStack(spacing: 5) {
            Image(systemName: tag.sfSymbol)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
            Text(tag.displayName)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(1)
        }
        .frame(width: 72, height: 60)
        .background(
            LinearGradient(
                colors: [color.opacity(0.92), color.opacity(0.6)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .overlay(alignment: .top) {
            LinearGradient(colors: [.white.opacity(0.28), .clear],
                           startPoint: .top, endPoint: .center)
                .clipShape(RoundedRectangle(cornerRadius: r))
        }
        .clipShape(RoundedRectangle(cornerRadius: r))
        // Near cube face
        .background(
            RoundedRectangle(cornerRadius: r)
                .fill(color.opacity(0.6))
                .offset(x: 4, y: 5)
        )
        // Far cube face
        .background(
            RoundedRectangle(cornerRadius: r)
                .fill(color.opacity(0.35))
                .offset(x: 8, y: 10)
        )
        .shadow(color: color.opacity(0.55), radius: 10, x: 0, y: 4)
        .shadow(color: .black.opacity(0.5), radius: 6, x: 4, y: 10)
    }

    private var cameraPermissionOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.slash.fill")
                .font(.system(size: 48))
                .foregroundStyle(StyleGuide.errorRed)
            Text("Camera Access Required")
                .font(StyleGuide.headingFont)
                .foregroundStyle(.white)
            Text("Go to Settings → Privacy → Camera\nand enable access for this app.")
                .font(StyleGuide.captionFont)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(StyleGuide.padding)
        .holoPanelStyle()
    }

    private func handlePinch(became isPinching: Bool) {
        if isPinching {
            guard let point = tracking.pinchPoint else { return }
            for (tag, frame) in tileFrames where frame.insetBy(dx: -10, dy: -10).contains(point) {
                grabbedTag = tag
                HapticManager.impact()
                return
            }
        } else {
            defer { grabbedTag = nil }
            guard let tag = grabbedTag, let point = tracking.pinchPoint else { return }
            if dropZoneFrame.insetBy(dx: -20, dy: -20).contains(point) {
                // Pick the smallest container frame containing the point (innermost nesting)
                let parentID = containerFrames
                    .filter { $0.value.contains(point) }
                    .min(by: { $0.value.width * $0.value.height < $1.value.width * $1.value.height })?
                    .key
                puzzleState.insertTag(tag, parentID: parentID)
                HapticManager.impact()
            }
        }
    }
}

// MARK: - ImmersiveBlockNode

private struct ImmersiveBlockNode: View {
    let node: DOMNode

    private var color: Color { StyleGuide.colorForCategory(node.tagType.category) }

    var body: some View {
        if node.tagType.canHaveChildren {
            containerBlock
        } else {
            leafBlock
        }
    }

    private var tagHeader: some View {
        HStack(spacing: 6) {
            Image(systemName: node.tagType.sfSymbol)
                .font(.system(size: 12, weight: .bold))
            Text(node.tagType.displayName)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
            Spacer()
        }
        .foregroundStyle(.white)
    }

    // Cube pill for void/leaf tags
    private var leafBlock: some View {
        tagHeader
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [color.opacity(0.9), color.opacity(0.65)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .overlay(alignment: .top) {
                // Glass highlight on top face
                LinearGradient(colors: [.white.opacity(0.3), .clear],
                               startPoint: .top, endPoint: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
            // Near side face
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(color.opacity(0.6))
                    .offset(x: 5, y: 6)
            )
            // Far side face
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(color.opacity(0.35))
                    .offset(x: 9, y: 11)
            )
            .shadow(color: color.opacity(0.6), radius: 12, x: 0, y: 6)
            .shadow(color: .black.opacity(0.5), radius: 6, x: 4, y: 10)
    }

    // Cube Scratch-style bracket + reports frame for pinch-nesting
    private var containerBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header top face
            tagHeader
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [color.opacity(0.92), color.opacity(0.65)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(alignment: .top) {
                    LinearGradient(colors: [.white.opacity(0.25), .clear],
                                   startPoint: .top, endPoint: .center)
                }

            // Left bracket + children slot
            HStack(alignment: .top, spacing: 0) {
                LinearGradient(
                    colors: [color.opacity(0.82), color.opacity(0.55)],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(width: 7)

                VStack(alignment: .leading, spacing: 6) {
                    if node.children.isEmpty {
                        Text("…")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.3))
                            .padding(.horizontal, 6)
                    } else {
                        ForEach(node.children) { child in
                            ImmersiveBlockNode(node: child)
                        }
                    }
                }
                .padding(.leading, 10)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(.black.opacity(0.22))

            // Closing strip
            LinearGradient(
                colors: [color.opacity(0.82), color.opacity(0.55)],
                startPoint: .leading, endPoint: .trailing
            )
            .frame(height: 9)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(alignment: .top) {
            LinearGradient(colors: [.white.opacity(0.18), .clear],
                           startPoint: .top, endPoint: .init(x: 0.5, y: 0.35))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .frame(height: 32)
                .allowsHitTesting(false)
        }
        // Near side face
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.6))
                .offset(x: 5, y: 6)
        )
        // Far side face
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.35))
                .offset(x: 9, y: 11)
        )
        .shadow(color: color.opacity(0.55), radius: 14, x: 0, y: 6)
        .shadow(color: .black.opacity(0.55), radius: 8, x: 4, y: 12)
        .background(GeometryReader { proxy in
            Color.clear.preference(key: NodeFrameKey.self,
                                   value: [node.id: proxy.frame(in: .named("immersive"))])
        })
    }
}
