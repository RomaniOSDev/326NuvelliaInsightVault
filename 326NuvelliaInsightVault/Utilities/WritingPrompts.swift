import Foundation

enum WritingPrompts {
    static let all: [String] = [
        "What changed today that you want to remember?",
        "Describe one frame that captures this moment.",
        "Who or what shaped the mood of this chapter?",
        "If this day were a film still, what would it look like?",
        "What detail would future-you thank you for writing down?",
        "Name the feeling under the surface of today.",
        "What surprised you, even quietly?",
        "Capture the soundtrack of this scene in words."
    ]

    static func random() -> String {
        all.randomElement() ?? all[0]
    }
}
