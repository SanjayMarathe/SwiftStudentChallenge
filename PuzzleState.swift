import SwiftUI

@MainActor
@Observable
final class PuzzleState {
    let level: LevelData
    var rootNodes: [DOMNode] = []
    var selectedNodeID: UUID? = nil
    var showCompletion: Bool = false
    var isCorrect: Bool = false

    init(level: LevelData) {
        self.level = level
    }

    func insertTag(_ tagType: TagType, parentID: UUID?, at index: Int? = nil) {
        let newNode = DOMNode(tagType: tagType)
        if let parentID = parentID {
            for i in rootNodes.indices {
                if rootNodes[i].updateNode(id: parentID, update: { node in
                    node.insertChild(newNode, at: index)
                }) {
                    return
                }
            }
        } else {
            if let index = index, index <= rootNodes.count {
                rootNodes.insert(newNode, at: index)
            } else {
                rootNodes.append(newNode)
            }
        }
    }

    func removeNode(id: UUID) {
        if let index = rootNodes.firstIndex(where: { $0.id == id }) {
            rootNodes.remove(at: index)
            return
        }
        for i in rootNodes.indices {
            if rootNodes[i].removeChild(id: id) != nil {
                return
            }
        }
    }

    func moveNode(id: UUID, toParent parentID: UUID?, at index: Int? = nil) {
        var movingNode: DOMNode?
        if let idx = rootNodes.firstIndex(where: { $0.id == id }) {
            movingNode = rootNodes.remove(at: idx)
        } else {
            for i in rootNodes.indices {
                if let removed = rootNodes[i].removeChild(id: id) {
                    movingNode = removed
                    break
                }
            }
        }
        guard let node = movingNode else { return }

        if let parentID = parentID {
            for i in rootNodes.indices {
                if rootNodes[i].updateNode(id: parentID, update: { parent in
                    parent.insertChild(node, at: index)
                }) {
                    return
                }
            }
        } else {
            if let index = index, index <= rootNodes.count {
                rootNodes.insert(node, at: index)
            } else {
                rootNodes.append(node)
            }
        }
    }

    func updateNodeText(id: UUID, text: String) {
        for i in rootNodes.indices {
            if rootNodes[i].updateNode(id: id, update: { node in
                node.textContent = text.isEmpty ? nil : text
            }) {
                return
            }
        }
    }

    func updateNodeAttribute(id: UUID, key: String, value: String?) {
        for i in rootNodes.indices {
            if rootNodes[i].updateNode(id: id, update: { node in
                if let value = value {
                    node.attributes[key] = value
                } else {
                    node.attributes.removeValue(forKey: key)
                }
            }) {
                return
            }
        }
    }

    func findNode(id: UUID) -> DOMNode? {
        for root in rootNodes {
            if let found = root.findNode(id: id) {
                return found
            }
        }
        return nil
    }

    func checkCompletion() {
        let target = level.targetTree
        isCorrect = rootNodes.count == 1 && DOMComparator.compare(rootNodes[0], to: target)
        showCompletion = true
    }
}
