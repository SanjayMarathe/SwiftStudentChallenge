import Foundation

enum HTMLCompiler {
    static func compile(_ node: DOMNode, indent: Int = 0) -> String {
        let pad = String(repeating: "  ", count: indent)
        let tag = node.tagType.rawValue

        let attrs = node.attributes.map { " \($0.key)=\"\($0.value)\"" }.joined()

        if node.tagType == .img {
            return "\(pad)<\(tag)\(attrs) />"
        }

        if node.children.isEmpty {
            let text = node.textContent ?? ""
            return "\(pad)<\(tag)\(attrs)>\(text)</\(tag)>"
        }

        var lines = ["\(pad)<\(tag)\(attrs)>"]
        if let text = node.textContent {
            lines.append("\(pad)  \(text)")
        }
        for child in node.children {
            lines.append(compile(child, indent: indent + 1))
        }
        lines.append("\(pad)</\(tag)>")
        return lines.joined(separator: "\n")
    }
}
