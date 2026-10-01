import SwiftUI

struct NoInternetView: View {
    var onRetry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 0)

            Image("openBookArt")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 160)
                .opacity(0.92)
                .shadow(color: Color("AppPrimary").opacity(0.25), radius: 16, y: 8)

            VStack(spacing: 12) {
                Text("No Internet Connection")
                    .font(.system(.title2, design: .serif).weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.center)
                Text("Please check your connection and try again.")
                    .font(.body)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }

            Spacer(minLength: 0)

            PrimaryButton(title: "Retry", action: onRetry)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
        }
        .storybookBackground()
        .preferredColorScheme(.dark)
    }
}

#Preview {
    NoInternetView(onRetry: {})
}
