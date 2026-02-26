import SwiftUI
import SceneKit

struct DOMSceneView: View {
    let rootNodes: [DOMNode]
    var selectedNodeID: UUID? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Space View", systemImage: "cube.fill")
                .font(StyleGuide.captionFont)
                .foregroundStyle(.white.opacity(0.5))

            if rootNodes.isEmpty {
                Text("Start building to see a space view")
                    .font(StyleGuide.captionFont)
                    .foregroundStyle(.white.opacity(0.3))
                    .frame(maxWidth: .infinity, minHeight: 80)
            } else {
                DOMSceneViewContainer(
                    rootNodes: rootNodes,
                    selectedNodeID: selectedNodeID
                )
                .frame(maxWidth: .infinity, minHeight: 200)
                .clipShape(RoundedRectangle(cornerRadius: StyleGuide.smallCornerRadius))
            }
        }
        .padding(StyleGuide.padding)
        .holoPanelStyle()
    }
}

private struct DOMSceneViewContainer: UIViewRepresentable {
    let rootNodes: [DOMNode]
    let selectedNodeID: UUID?

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = UIColor(red: 0x1A / 255, green: 0x12 / 255, blue: 0x38 / 255, alpha: 1)
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = false
        scnView.antialiasingMode = .multisampling4X

        let scene = DOMEntityBuilder.buildScene(
            from: rootNodes,
            selectedNodeID: selectedNodeID
        )

        // Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 60
        cameraNode.camera?.zNear = 0.01
        cameraNode.camera?.zFar = 100
        cameraNode.position = SCNVector3(0, 0.5, 5)
        cameraNode.look(at: SCNVector3(0, -0.5, 0))
        scene.rootNode.addChildNode(cameraNode)

        scnView.scene = scene
        scnView.pointOfView = cameraNode

        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        let scene = DOMEntityBuilder.buildScene(
            from: rootNodes,
            selectedNodeID: selectedNodeID
        )

        // Preserve camera from existing scene
        if let existingCamera = scnView.pointOfView {
            let cameraNode = existingCamera.clone()
            scene.rootNode.addChildNode(cameraNode)
            scnView.scene = scene
            scnView.pointOfView = cameraNode
        } else {
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.camera?.fieldOfView = 60
            cameraNode.camera?.zNear = 0.01
            cameraNode.camera?.zFar = 100
            cameraNode.position = SCNVector3(0, 0.5, 5)
            cameraNode.look(at: SCNVector3(0, -0.5, 0))
            scene.rootNode.addChildNode(cameraNode)
            scnView.scene = scene
            scnView.pointOfView = cameraNode
        }
    }
}
