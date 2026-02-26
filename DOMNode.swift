import Foundation

struct DOMNode: Identifiable, Sendable, Equatable {
    let id: UUID
    var tagType: TagType
    var attributes: [String: String]
    var children: [DOMNode]
    var textContent: String?

    init(
        id: UUID = UUID(),
        tagType: TagType,
        attributes: [String: String] = [:],
        children: [DOMNode] = [],
        textContent: String? = nil
    ) {
        self.id = id
        self.tagType = tagType
        self.attributes = attributes
        self.children = children
        self.textContent = textContent
    }

    mutating func insertChild(_ child: DOMNode, at index: Int? = nil) {
        guard tagType.canHaveChildren else { return }
        if let index = index, index <= children.count {
            children.insert(child, at: index)
        } else {
            children.append(child)
        }
    }

    mutating func removeChild(id: UUID) -> DOMNode? {
        if let index = children.firstIndex(where: { $0.id == id }) {
            return children.remove(at: index)
        }
        for i in children.indices {
            if let removed = children[i].removeChild(id: id) {
                return removed
            }
        }
        return nil
    }

    func findNode(id: UUID) -> DOMNode? {
        if self.id == id { return self }
        for child in children {
            if let found = child.findNode(id: id) {
                return found
            }
        }
        return nil
    }

    mutating func updateNode(id: UUID, update: (inout DOMNode) -> Void) -> Bool {
        if self.id == id {
            update(&self)
            return true
        }
        for i in children.indices {
            if children[i].updateNode(id: id, update: update) {
                return true
            }
        }
        return false
    }
}
