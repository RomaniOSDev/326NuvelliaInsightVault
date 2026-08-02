import UIKit

enum PhotoStorage {
    private static var directory: URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("VaultPhotos", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    static func save(_ image: UIImage, preferredName: String? = nil) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.82) else { return nil }
        let name = preferredName ?? "\(UUID().uuidString).jpg"
        let url = directory.appendingPathComponent(name)
        do {
            try data.write(to: url, options: .atomic)
            return name
        } catch {
            return nil
        }
    }

    static func load(_ fileName: String?) -> UIImage? {
        guard let fileName else { return nil }
        let url = directory.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    static func delete(_ fileName: String?) {
        guard let fileName else { return }
        let url = directory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: url)
    }
}
