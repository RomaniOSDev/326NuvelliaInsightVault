import Foundation

enum MoodTag: String, CaseIterable, Identifiable, Codable {
    case calm
    case hype
    case nostalgic
    case reflective
    case joyful
    case moody

    var id: String { rawValue }

    var title: String {
        switch self {
        case .calm: return "Calm"
        case .hype: return "Hype"
        case .nostalgic: return "Nostalgic"
        case .reflective: return "Reflective"
        case .joyful: return "Joyful"
        case .moody: return "Moody"
        }
    }

    var symbol: String {
        switch self {
        case .calm: return "leaf.fill"
        case .hype: return "bolt.fill"
        case .nostalgic: return "clock.arrow.circlepath"
        case .reflective: return "text.quote"
        case .joyful: return "sun.max.fill"
        case .moody: return "cloud.moon.fill"
        }
    }
}
