import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: AppStore
    @State private var page = 0

    private let pages: [(title: String, subtitle: String, image: String)] = [
        (
            "Organize Your Media",
            "Easily convert your photos into visual chapters.",
            "chaptersArt"
        ),
        (
            "Add Descriptive Notes",
            "Attach detailed notes to each chapter for context.",
            "bannerJournals"
        ),
        (
            "Begin Your Story",
            "Start by creating your first visual chapter today!",
            "openBookArt"
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: 24) {
                        Image(item.image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 220)
                            .shadow(color: Color("AppPrimary").opacity(0.35), radius: 18, y: 10)
                            .padding(.top, 40)
                        VStack(spacing: 12) {
                            Text(item.title)
                                .font(.system(.title2, design: .serif).weight(.bold))
                                .foregroundStyle(Color("AppTextPrimary"))
                                .multilineTextAlignment(.center)
                            Text(item.subtitle)
                                .font(.body)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                        }
                        Spacer(minLength: 0)
                    }
                    .tag(index)
                    .padding(.horizontal, 24)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .onChange(of: page) { _ in
                HapticFeedback.selection()
            }

            PrimaryButton(title: page == pages.count - 1 ? "Get Started" : "Continue") {
                if page < pages.count - 1 {
                    withAnimation { page += 1 }
                } else {
                    store.completeOnboarding()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .storybookBackground()
    }
}
