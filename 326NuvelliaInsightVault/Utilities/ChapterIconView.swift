import SwiftUI

struct ChapterIconView: View {
    let icon: String
    var size: CGFloat = 28

    var body: some View {
        Group {
            if icon.hasPrefix("sf:") {
                Image(systemName: String(icon.dropFirst(3)))
                    .font(.system(size: size * 0.55, weight: .semibold))
            } else {
                Text(icon.isEmpty ? "📖" : icon)
                    .font(.system(size: size * 0.65))
            }
        }
        .frame(width: size + 8, height: size + 8)
    }
}
