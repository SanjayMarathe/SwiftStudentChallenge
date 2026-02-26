import SwiftUI

enum TagCategory: String, Sendable {
    case structural = "Containers"
    case typography = "Text"
    case media = "Pictures"
}

enum TagType: String, CaseIterable, Sendable, Codable {
    case div
    case section
    case header
    case nav
    case main
    case footer
    case h1
    case h2
    case h3
    case p
    case span
    case img
    case a

    var displayName: String {
        switch self {
        case .div: return "<div>"
        case .section: return "<section>"
        case .header: return "<header>"
        case .nav: return "<nav>"
        case .main: return "<main>"
        case .footer: return "<footer>"
        case .h1: return "<h1>"
        case .h2: return "<h2>"
        case .h3: return "<h3>"
        case .p: return "<p>"
        case .span: return "<span>"
        case .img: return "<img>"
        case .a: return "<a>"
        }
    }

    var category: TagCategory {
        switch self {
        case .div, .section, .header, .nav, .main, .footer:
            return .structural
        case .h1, .h2, .h3, .p, .span, .a:
            return .typography
        case .img:
            return .media
        }
    }

    var canHaveChildren: Bool {
        switch self {
        case .img:
            return false
        default:
            return true
        }
    }

    var sfSymbol: String {
        switch self {
        case .div: return "square.dashed"
        case .section: return "rectangle.split.3x1"
        case .header: return "rectangle.topthird.inset.filled"
        case .nav: return "sidebar.left"
        case .main: return "rectangle.center.inset.filled"
        case .footer: return "rectangle.bottomthird.inset.filled"
        case .h1: return "textformat.size.larger"
        case .h2: return "textformat.size"
        case .h3: return "textformat.size.smaller"
        case .p: return "text.alignleft"
        case .span: return "text.cursor"
        case .img: return "photo"
        case .a: return "link"
        }
    }
}
