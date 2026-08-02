import SwiftUI

struct EmptyStateView: View {
    let imageName: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 160)
                .opacity(0.92)
                .shadow(color: Color("AppPrimary").opacity(0.25), radius: 16, y: 8)
            Text(title)
                .font(.system(.title2, design: .serif).weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .multilineTextAlignment(.center)
            Text(message)
                .font(.body)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
    }
}
