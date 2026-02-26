import SwiftUI

struct AttributeInspectorView: View {
    @Bindable var puzzleState: PuzzleState
    let nodeID: UUID

    private var node: DOMNode? {
        puzzleState.findNode(id: nodeID)
    }

    var body: some View {
        if let node = node {
            InspectorContent(node: node, nodeID: nodeID, puzzleState: puzzleState)
        }
    }
}

private struct InspectorContent: View {
    let node: DOMNode
    let nodeID: UUID
    @Bindable var puzzleState: PuzzleState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerRow
            Divider().overlay(.white.opacity(0.1))
            textSection
            fontSizeSection
            colorSection
            paddingSection
        }
        .padding(StyleGuide.padding)
        .frame(width: 280)
        .background(StyleGuide.surface)
        .clipShape(RoundedRectangle(cornerRadius: StyleGuide.cornerRadius))
    }

    private var headerRow: some View {
        HStack {
            Text("Inspector")
                .font(StyleGuide.headingFont)
                .foregroundStyle(.white)
            Spacer()
            TagBlockView(tagType: node.tagType, isDraggable: false)
        }
    }

    private var textSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Text Content")
                .font(StyleGuide.captionFont)
                .foregroundStyle(.white.opacity(0.5))
            TextField("Enter text...", text: textBinding)
                .font(StyleGuide.codeFont)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var textBinding: Binding<String> {
        Binding(
            get: { node.textContent ?? "" },
            set: { puzzleState.updateNodeText(id: nodeID, text: $0) }
        )
    }

    private var fontSizeSection: some View {
        let currentSize = node.attributes["font-size"].flatMap { Double($0) } ?? 16.0
        return VStack(alignment: .leading, spacing: 4) {
            Text("Font Size: \(Int(currentSize))px")
                .font(StyleGuide.captionFont)
                .foregroundStyle(.white.opacity(0.5))
            Slider(
                value: Binding(
                    get: { currentSize },
                    set: { puzzleState.updateNodeAttribute(id: nodeID, key: "font-size", value: "\(Int($0))") }
                ),
                in: 10...48,
                step: 1
            )
            .tint(StyleGuide.teal)
        }
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Color")
                .font(StyleGuide.captionFont)
                .foregroundStyle(.white.opacity(0.5))
            HStack(spacing: 8) {
                ForEach(colorNames, id: \.self) { colorName in
                    ColorPresetButton(
                        colorName: colorName,
                        isSelected: node.attributes["color"] == colorName
                    ) {
                        puzzleState.updateNodeAttribute(id: nodeID, key: "color", value: colorName)
                    }
                }
            }
        }
    }

    private var paddingSection: some View {
        let currentPadding = node.attributes["padding"].flatMap { Double($0) } ?? 0
        return VStack(alignment: .leading, spacing: 4) {
            Text("Padding: \(Int(currentPadding))px")
                .font(StyleGuide.captionFont)
                .foregroundStyle(.white.opacity(0.5))
            Slider(
                value: Binding(
                    get: { currentPadding },
                    set: { val in
                        let v: String? = val > 0 ? "\(Int(val))" : nil
                        puzzleState.updateNodeAttribute(id: nodeID, key: "padding", value: v)
                    }
                ),
                in: 0...32,
                step: 2
            )
            .tint(StyleGuide.indigo)
        }
    }

    private var colorNames: [String] {
        ["white", "red", "blue", "green", "orange", "purple", "teal"]
    }
}

private struct ColorPresetButton: View {
    let colorName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(DOMRenderer.colorFromString(colorName))
                .frame(width: 24, height: 24)
                .overlay(
                    Circle()
                        .strokeBorder(.white, lineWidth: isSelected ? 2 : 0)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(colorName) color")
    }
}
