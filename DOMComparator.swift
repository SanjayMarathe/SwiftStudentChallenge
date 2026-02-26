import Foundation

enum DOMComparator {
    static func compare(_ userNode: DOMNode, to targetNode: DOMNode) -> Bool {
        guard userNode.tagType == targetNode.tagType else { return false }
        guard userNode.children.count == targetNode.children.count else { return false }

        if let targetText = targetNode.textContent {
            guard let userText = userNode.textContent,
                  userText.trimmingCharacters(in: .whitespaces).lowercased() ==
                  targetText.trimmingCharacters(in: .whitespaces).lowercased()
            else { return false }
        }

        for targetAttr in targetNode.attributes {
            guard userNode.attributes[targetAttr.key]?.lowercased() == targetAttr.value.lowercased() else {
                return false
            }
        }

        for (index, targetChild) in targetNode.children.enumerated() {
            if !compare(userNode.children[index], to: targetChild) {
                return false
            }
        }

        return true
    }

    static func hints(userNode: DOMNode?, targetNode: DOMNode) -> [String] {
        var hints: [String] = []

        guard let userNode = userNode else {
            hints.append("Start by adding a \(targetNode.tagType.displayName) tag.")
            return hints
        }

        if userNode.tagType != targetNode.tagType {
            hints.append("Root should be \(targetNode.tagType.displayName), not \(userNode.tagType.displayName).")
            return hints
        }

        if userNode.children.count < targetNode.children.count {
            let missing = targetNode.children.count - userNode.children.count
            hints.append("Need \(missing) more child element\(missing == 1 ? "" : "s") inside \(userNode.tagType.displayName).")
        } else if userNode.children.count > targetNode.children.count {
            hints.append("Too many children inside \(userNode.tagType.displayName). Remove \(userNode.children.count - targetNode.children.count).")
        }

        for (index, targetChild) in targetNode.children.enumerated() {
            if index < userNode.children.count {
                let userChild = userNode.children[index]
                if userChild.tagType != targetChild.tagType {
                    hints.append("Child \(index + 1) should be \(targetChild.tagType.displayName), not \(userChild.tagType.displayName).")
                } else if let targetText = targetChild.textContent, userChild.textContent != targetText {
                    hints.append("Update text in \(targetChild.tagType.displayName) to \"\(targetText)\".")
                }
            }
        }

        if hints.isEmpty {
            hints.append("Almost there! Check nesting and text content.")
        }

        return hints
    }
}
