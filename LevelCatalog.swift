import Foundation

enum LevelCatalog {
    static let levels: [LevelData] = [level1, level2, level3]

    // Level 1: Simple heading + paragraph
    static let level1 = LevelData(
        id: 1,
        title: "Hello Web",
        subtitle: "Heading + Paragraph",
        description: "Build a simple page with a heading and paragraph inside a div.",
        difficulty: .beginner,
        targetTree: DOMNode(
            tagType: .div,
            children: [
                DOMNode(tagType: .h1, textContent: "Hello World"),
                DOMNode(tagType: .p, textContent: "Welcome to SpatialDOM!")
            ]
        ),
        availableTags: [.div, .h1, .p]
    )

    // Level 2: Profile card
    static let level2 = LevelData(
        id: 2,
        title: "Profile Card",
        subtitle: "Nested Structure",
        description: "Create a profile card with an image, name, and bio.",
        difficulty: .intermediate,
        targetTree: DOMNode(
            tagType: .div,
            children: [
                DOMNode(tagType: .img, attributes: ["src": "avatar.png", "alt": "Profile photo"]),
                DOMNode(tagType: .h2, textContent: "Jane Doe"),
                DOMNode(tagType: .p, textContent: "iOS Developer & Designer")
            ]
        ),
        availableTags: [.div, .h2, .p, .img, .span]
    )

    // Level 3: Multi-section layout
    static let level3 = LevelData(
        id: 3,
        title: "Page Layout",
        subtitle: "Multi-Section",
        description: "Build a full page with header, main content, and footer.",
        difficulty: .advanced,
        targetTree: DOMNode(
            tagType: .div,
            children: [
                DOMNode(
                    tagType: .header,
                    children: [
                        DOMNode(tagType: .h1, textContent: "My Site")
                    ]
                ),
                DOMNode(
                    tagType: .main,
                    children: [
                        DOMNode(tagType: .h2, textContent: "Welcome"),
                        DOMNode(tagType: .p, textContent: "This is the main content.")
                    ]
                ),
                DOMNode(
                    tagType: .footer,
                    children: [
                        DOMNode(tagType: .p, textContent: "© 2026")
                    ]
                )
            ]
        ),
        availableTags: [.div, .header, .main, .footer, .h1, .h2, .p]
    )
}
