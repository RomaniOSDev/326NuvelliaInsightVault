import SwiftUI

struct RingLoadingIndicator: View {
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("AppSurface").opacity(0.55), lineWidth: 3)
                .frame(width: 52, height: 52)
            Circle()
                .trim(from: 0, to: 0.72)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color("AppPrimary"),
                            Color("AppAccent"),
                            Color("AppPrimary")
                        ]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 52, height: 52)
                .rotationEffect(.degrees(rotation))
        }
        .shadow(color: Color("AppPrimary").opacity(0.35), radius: 10, y: 4)
        .onAppear {
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 0)

            Image("openBookArt")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 200)
                .shadow(color: Color("AppPrimary").opacity(0.35), radius: 18, y: 10)

            VStack(spacing: 10) {
                Text("Nuvellia Insight Vault")
                    .font(.system(.title2, design: .serif).weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.center)
                Text("Opening your journal")
                    .font(.body)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 8)

            RingLoadingIndicator()
                .padding(.top, 8)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .storybookBackground()
        .preferredColorScheme(.dark)
    }
}

#Preview {
    LoadingView()
}
