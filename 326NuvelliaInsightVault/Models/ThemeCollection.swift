import Foundation

struct ThemeCollection: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let tags: [String]
    let primaryHex: String
    let accentHex: String
}
