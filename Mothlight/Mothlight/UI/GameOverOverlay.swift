import SwiftUI

struct GameOverOverlay: View {
    @ObservedObject var viewModel: GameViewModel
    @ObservedObject private var ads = AdCoordinator.shared

    var body: some View {
        VStack(spacing: 16) {
            Text("Out of glow")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.white)
                .accessibilityAddTraits(.isHeader)

            Text("Score \(viewModel.lastScore)")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.9))

            if viewModel.lastScore >= viewModel.highScore && viewModel.lastScore > 0 {
                Text("New best!")
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.78, green: 0.95, blue: 0.62))
            } else {
                Text("Best \(viewModel.highScore)")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.7))
            }

            if viewModel.canOfferRewardedContinue, ads.canShowRewardedContinue {
                Button("Watch ad to continue") {
                    viewModel.requestRewardedContinue()
                }
                .font(.headline)
                .foregroundStyle(Color(red: 0.78, green: 0.95, blue: 0.62))
                .accessibilityHint("Shows a rewarded video and resumes your run once")
            }

            Button("Try again") {
                viewModel.restartAfterGameOver()
            }
            .buttonStyle(MothlightPrimaryButtonStyle())
            .padding(.top, 4)

            Button("Home") {
                viewModel.returnToMenu()
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white.opacity(0.65))
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.black.opacity(0.55))
                .padding(.horizontal, 20)
        )
        .accessibilityElement(children: .contain)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
    }
}
