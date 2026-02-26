import SceneKit
import SwiftUI

@MainActor
enum DOMEntityBuilder {
    // MARK: - Layout constants
    private static let wallThickness: CGFloat = 0.06
    private static let headerHeight: CGFloat = 0.3
    private static let innerPadding: CGFloat = 0.1
    private static let childGap: CGFloat = 0.08
    private static let siblingSpacing: CGFloat = 0.15
    private static let leafWidth: CGFloat = 0.8
    private static let leafHeight: CGFloat = 0.35
    private static let blockDepth: CGFloat = 0.3
    private static let textContentHeight: CGFloat = 0.25

    // MARK: - Size measurement

    struct NodeSize {
        var width: CGFloat
        var height: CGFloat
        var depth: CGFloat
    }

    private static func measure(_ node: DOMNode) -> NodeSize {
        // Leaf with no children
        if node.children.isEmpty {
            let h = node.textContent != nil ? leafHeight + textContentHeight : leafHeight
            return NodeSize(width: leafWidth, height: h, depth: blockDepth)
        }

        // Parent: stack children vertically inside
        let childSizes = node.children.map { measure($0) }
        let maxChildWidth = childSizes.map(\.width).max() ?? 0
        let totalChildHeight = childSizes.map(\.height).reduce(0, +) + CGFloat(max(0, childSizes.count - 1)) * childGap
        let maxChildDepth = childSizes.map(\.depth).max() ?? blockDepth

        let interiorWidth = maxChildWidth + 2 * innerPadding
        let interiorHeight = headerHeight + totalChildHeight + 2 * innerPadding

        return NodeSize(
            width: max(leafWidth, interiorWidth + 2 * wallThickness),
            height: interiorHeight + wallThickness, // bottom wall
            depth: max(blockDepth, maxChildDepth + wallThickness)
        )
    }

    // MARK: - Public API

    static func buildScene(
        from rootNodes: [DOMNode],
        selectedNodeID: UUID? = nil
    ) -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor(red: 0x1A / 255, green: 0x12 / 255, blue: 0x38 / 255, alpha: 1)

        // Lighting
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(red: 0.7, green: 0.65, blue: 0.9, alpha: 1) // faint blue-purple nebula tint
        ambientLight.light?.intensity = 500
        scene.rootNode.addChildNode(ambientLight)

        let directional = SCNNode()
        directional.light = SCNLight()
        directional.light?.type = .directional
        directional.light?.color = UIColor.white
        directional.light?.intensity = 700
        directional.eulerAngles = SCNVector3(-Float.pi / 3, Float.pi / 4, 0)
        scene.rootNode.addChildNode(directional)

        guard !rootNodes.isEmpty else { return scene }

        let container = SCNNode()
        container.name = "DOMContainer"

        var results: [(SCNNode, NodeSize)] = []
        for node in rootNodes {
            let size = measure(node)
            let scnNode = buildNode(for: node, size: size, depth: 0, selectedNodeID: selectedNodeID)
            results.append((scnNode, size))
        }

        // Lay out root nodes side by side
        let totalWidth = results.reduce(CGFloat(0)) { $0 + $1.1.width } + CGFloat(max(0, results.count - 1)) * siblingSpacing
        var xOff = -totalWidth / 2
        for (scnNode, size) in results {
            scnNode.position.x = Float(xOff + size.width / 2)
            container.addChildNode(scnNode)
            xOff += size.width + siblingSpacing
        }

        scene.rootNode.addChildNode(container)
        return scene
    }

    // MARK: - Recursive builder

    private static func buildNode(
        for node: DOMNode,
        size: NodeSize,
        depth: Int,
        selectedNodeID: UUID?
    ) -> SCNNode {
        let anchor = SCNNode()
        anchor.name = node.id.uuidString
        let isSelected = node.id == selectedNodeID

        if node.children.isEmpty {
            // Leaf node — solid box
            let block = makeLeafBlock(node: node, size: size, isSelected: isSelected, depth: depth)
            anchor.addChildNode(block)
        } else {
            // Parent node — open-front container with children inside
            let container = makeContainer(node: node, size: size, isSelected: isSelected, depth: depth)
            anchor.addChildNode(container)

            // Place children stacked vertically inside
            let childSizes = node.children.map { measure($0) }
            var yOff = Float(size.height / 2 - headerHeight - innerPadding)

            for (i, child) in node.children.enumerated() {
                let childSize = childSizes[i]
                let childNode = buildNode(for: child, size: childSize, depth: depth + 1, selectedNodeID: selectedNodeID)
                yOff -= Float(childSize.height / 2)
                childNode.position = SCNVector3(0, yOff, Float(wallThickness / 2))
                anchor.addChildNode(childNode)
                yOff -= Float(childSize.height / 2 + childGap)
            }
        }

        return anchor
    }

    // MARK: - Leaf block (solid box with tag label + optional text content)

    private static func makeLeafBlock(node: DOMNode, size: NodeSize, isSelected: Bool, depth: Int) -> SCNNode {
        let group = SCNNode()

        let box = SCNBox(width: size.width, height: size.height, length: size.depth, chamferRadius: 0.04)
        let color = uiColor(for: node.tagType.category)
        let mat = SCNMaterial()
        mat.diffuse.contents = isSelected ? color : color.withAlphaComponent(0.85)
        mat.specular.contents = UIColor.white.withAlphaComponent(0.5)
        mat.roughness.contents = NSNumber(value: isSelected ? 0.1 : 0.15)
        mat.metalness.contents = NSNumber(value: 0.0)
        mat.emission.contents = color.withAlphaComponent(isSelected ? 0.3 : 0.1)
        box.materials = [mat]

        let boxNode = SCNNode(geometry: box)
        group.addChildNode(boxNode)

        // Tag label at top of the block
        let label = makeTagLabel(node.tagType.rawValue, color: .white, fontSize: 0.12)
        label.position = SCNVector3(0, Float(size.height / 2) - 0.14, Float(size.depth / 2) + 0.01)
        group.addChildNode(label)

        // Text content below tag label if present
        if let text = node.textContent, !text.isEmpty {
            let contentLabel = makeContentLabel(text)
            contentLabel.position = SCNVector3(0, Float(size.height / 2) - 0.14 - 0.22, Float(size.depth / 2) + 0.01)
            group.addChildNode(contentLabel)
        }

        // Entry animation
        applyEntryAnimation(to: group, depth: depth, isSelected: isSelected)

        return group
    }

    // MARK: - Container (open-front U-shape for parents)

    private static func makeContainer(node: DOMNode, size: NodeSize, isSelected: Bool, depth: Int) -> SCNNode {
        let group = SCNNode()
        let color = uiColor(for: node.tagType.category)
        let alpha: CGFloat = isSelected ? 0.9 : 0.7

        // Header bar (top)
        let headerBox = SCNBox(
            width: size.width,
            height: headerHeight,
            length: size.depth,
            chamferRadius: 0.04
        )
        headerBox.materials = [makeMaterial(color: color, alpha: alpha, isSelected: isSelected)]
        let headerNode = SCNNode(geometry: headerBox)
        headerNode.position.y = Float(size.height / 2 - headerHeight / 2)
        group.addChildNode(headerNode)

        // Tag label on header front face
        let label = makeTagLabel(node.tagType.rawValue, color: .white, fontSize: 0.14)
        label.position = SCNVector3(0, Float(size.height / 2 - headerHeight / 2), Float(size.depth / 2) + 0.01)
        group.addChildNode(label)

        // Bottom bar
        let bottomBox = SCNBox(
            width: size.width,
            height: wallThickness,
            length: size.depth,
            chamferRadius: 0.02
        )
        bottomBox.materials = [makeMaterial(color: color, alpha: alpha, isSelected: isSelected)]
        let bottomNode = SCNNode(geometry: bottomBox)
        bottomNode.position.y = Float(-size.height / 2 + wallThickness / 2)
        group.addChildNode(bottomNode)

        // Left wall
        let sideHeight = size.height - headerHeight - wallThickness
        let leftBox = SCNBox(
            width: wallThickness,
            height: sideHeight,
            length: size.depth,
            chamferRadius: 0.02
        )
        leftBox.materials = [makeMaterial(color: color, alpha: alpha, isSelected: isSelected)]
        let leftNode = SCNNode(geometry: leftBox)
        leftNode.position = SCNVector3(
            Float(-size.width / 2 + wallThickness / 2),
            Float(size.height / 2 - headerHeight - sideHeight / 2),
            0
        )
        group.addChildNode(leftNode)

        // Right wall
        let rightBox = SCNBox(
            width: wallThickness,
            height: sideHeight,
            length: size.depth,
            chamferRadius: 0.02
        )
        rightBox.materials = [makeMaterial(color: color, alpha: alpha, isSelected: isSelected)]
        let rightNode = SCNNode(geometry: rightBox)
        rightNode.position = SCNVector3(
            Float(size.width / 2 - wallThickness / 2),
            Float(size.height / 2 - headerHeight - sideHeight / 2),
            0
        )
        group.addChildNode(rightNode)

        // Back wall (closes the back, front stays open)
        let backBox = SCNBox(
            width: size.width - 2 * wallThickness,
            height: sideHeight,
            length: wallThickness,
            chamferRadius: 0
        )
        backBox.materials = [makeMaterial(color: color, alpha: alpha * 0.5, isSelected: isSelected)]
        let backNode = SCNNode(geometry: backBox)
        backNode.position = SCNVector3(
            0,
            Float(size.height / 2 - headerHeight - sideHeight / 2),
            Float(-size.depth / 2 + wallThickness / 2)
        )
        group.addChildNode(backNode)

        // Entry animation
        applyEntryAnimation(to: group, depth: depth, isSelected: isSelected)

        return group
    }

    // MARK: - Labels

    private static func makeTagLabel(_ text: String, color: UIColor, fontSize: CGFloat) -> SCNNode {
        let scnText = SCNText(string: text, extrusionDepth: 0.005)
        scnText.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        scnText.flatness = 0.1
        scnText.firstMaterial?.diffuse.contents = color
        scnText.firstMaterial?.isDoubleSided = true

        let node = SCNNode(geometry: scnText)
        let (minB, maxB) = node.boundingBox
        let w = maxB.x - minB.x
        let h = maxB.y - minB.y
        node.pivot = SCNMatrix4MakeTranslation(w / 2 + minB.x, h / 2 + minB.y, 0)

        return node
    }

    private static func makeContentLabel(_ text: String) -> SCNNode {
        let displayText = text.count > 30 ? String(text.prefix(27)) + "..." : text
        let scnText = SCNText(string: "\"\(displayText)\"", extrusionDepth: 0.003)
        scnText.font = UIFont(name: "Menlo", size: 0.08) ?? UIFont.systemFont(ofSize: 0.08)
        scnText.flatness = 0.1
        scnText.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.7)
        scnText.firstMaterial?.isDoubleSided = true

        let node = SCNNode(geometry: scnText)
        let (minB, maxB) = node.boundingBox
        let w = maxB.x - minB.x
        let h = maxB.y - minB.y
        node.pivot = SCNMatrix4MakeTranslation(w / 2 + minB.x, h / 2 + minB.y, 0)

        return node
    }

    // MARK: - Helpers

    private static func makeMaterial(color: UIColor, alpha: CGFloat, isSelected: Bool) -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = color.withAlphaComponent(alpha)
        mat.specular.contents = UIColor.white.withAlphaComponent(0.4)
        mat.roughness.contents = NSNumber(value: isSelected ? 0.1 : 0.2)
        mat.metalness.contents = NSNumber(value: 0.0)
        mat.emission.contents = color.withAlphaComponent(isSelected ? 0.25 : 0.1)
        return mat
    }

    private static func applyEntryAnimation(to node: SCNNode, depth: Int, isSelected: Bool) {
        node.scale = SCNVector3(0.01, 0.01, 0.01)
        let delay = Double(depth) * 0.1
        let target: CGFloat = isSelected ? 1.08 : 1.0
        let action = SCNAction.sequence([
            SCNAction.wait(duration: delay),
            SCNAction.scale(to: target, duration: 0.35)
        ])
        action.timingMode = .easeOut
        node.runAction(action)
    }

    // MARK: - Colors (Cosmic palette)

    private static func uiColor(for category: TagCategory) -> UIColor {
        switch category {
        case .structural:
            return UIColor(red: 0x3F / 255, green: 0x51 / 255, blue: 0xB5 / 255, alpha: 1) // Planet Blue
        case .typography:
            return UIColor(red: 0x00 / 255, green: 0xC8 / 255, blue: 0x53 / 255, alpha: 1) // Asteroid Green
        case .media:
            return UIColor(red: 0xFF / 255, green: 0x6D / 255, blue: 0x00 / 255, alpha: 1) // Solar Orange
        }
    }
}
