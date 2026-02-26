import SwiftUI

struct TreeDisplayView: View {
    @Bindable var puzzleState: PuzzleState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Your Build", systemImage: "list.bullet.indent")
                .font(StyleGuide.captionFont)
                .foregroundStyle(.white.opacity(0.5))

            treeContent
        }
        .padding(StyleGuide.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .holoPanelStyle()
    }

    @ViewBuilder
    private var treeContent: some View {
        if puzzleState.rootNodes.isEmpty {
            emptyDropZone
        } else {
            populatedTree
        }
    }

    private var emptyDropZone: some View {
        DropZoneView(label: "Drop a block here to start")
            .dropDestination(for: String.self) { items, _ in
                handleDrop(items: items, parentID: nil)
            }
    }

    private var populatedTree: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(puzzleState.rootNodes) { node in
                TreeNodeView(node: node, depth: 0, puzzleState: puzzleState)
            }

            DropZoneView(label: "Drop here", compact: true)
                .dropDestination(for: String.self) { items, _ in
                    handleDrop(items: items, parentID: nil)
                }
        }
    }

    private func handleDrop(items: [String], parentID: UUID?) -> Bool {
        guard let raw = items.first, let tag = TagType(rawValue: raw) else { return false }
        withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
            puzzleState.insertTag(tag, parentID: parentID)
        }
        HapticManager.impact()
        return true
    }
}

struct TreeNodeView: View {
    let node: DOMNode
    let depth: Int
    @Bindable var puzzleState: PuzzleState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            nodeRow
            childrenSection
        }
    }

    private var isSelected: Bool {
        puzzleState.selectedNodeID == node.id
    }

    private var nodeRow: some View {
        HStack(spacing: 4) {
            TagBlockView(
                tagType: node.tagType,
                isDraggable: false,
                isSelected: isSelected,
                onTap: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        puzzleState.selectedNodeID = isSelected ? nil : node.id
                    }
                }
            )

            nodeText

            Spacer()

            removeButton
        }
        .padding(.leading, CGFloat(depth) * 20)
        .padding(.vertical, 3)
    }

    @ViewBuilder
    private var nodeText: some View {
        if let text = node.textContent {
            Text("\"\(text)\"")
                .font(StyleGuide.codeFont)
                .foregroundStyle(.white.opacity(0.5))
                .lineLimit(1)
        }
    }

    private var removeButton: some View {
        Button {
            withAnimation(.spring(duration: 0.3)) {
                puzzleState.removeNode(id: node.id)
            }
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.3))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Remove \(node.tagType.displayName)")
    }

    @ViewBuilder
    private var childrenSection: some View {
        if node.tagType.canHaveChildren {
            ForEach(node.children) { child in
                TreeNodeView(node: child, depth: depth + 1, puzzleState: puzzleState)
            }

            DropZoneView(label: "Drop inside \(node.tagType.displayName)", compact: true)
                .padding(.leading, CGFloat(depth + 1) * 20)
                .dropDestination(for: String.self) { items, _ in
                    guard let raw = items.first, let tag = TagType(rawValue: raw) else { return false }
                    withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                        puzzleState.insertTag(tag, parentID: node.id)
                    }
                    HapticManager.impact()
                    return true
                }
        }
    }
}
