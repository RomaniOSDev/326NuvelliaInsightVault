import SwiftUI

struct JournalThemesContainerView: View {
    @Binding var segment: JournalThemesSegment

    var body: some View {
        VStack(spacing: 12) {
            JournalThemesSegmentControl(selection: $segment)
                .padding(.horizontal, 20)
                .padding(.top, 8)

            Group {
                switch segment {
                case .journal:
                    JournalView()
                case .themes:
                    ThemesView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
