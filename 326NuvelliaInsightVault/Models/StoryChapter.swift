import Foundation

struct StoryChapter: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var icon: String
    var chapterDescription: String
    var createdAt: Date
    var isPinned: Bool
    var imageFileName: String?

    init(
        id: UUID = UUID(),
        title: String,
        icon: String,
        chapterDescription: String,
        createdAt: Date = Date(),
        isPinned: Bool = false,
        imageFileName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.chapterDescription = chapterDescription
        self.createdAt = createdAt
        self.isPinned = isPinned
        self.imageFileName = imageFileName
    }

    enum CodingKeys: String, CodingKey {
        case id, title, icon, chapterDescription, createdAt, isPinned, imageFileName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        icon = try container.decode(String.self, forKey: .icon)
        chapterDescription = try container.decode(String.self, forKey: .chapterDescription)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        imageFileName = try container.decodeIfPresent(String.self, forKey: .imageFileName)
    }
}
