import SpriteKit
import SwiftUI

struct GameContainerView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            SpriteView(scene: viewModel.scene, options: [.allowsTransparency])
                .ignoresSafeArea()
                .accessibilityLabel("Mothlight playfield")
                .accessibilityHint("Tap anywhere to flap through the forest")

            overlayContent
        }
        .background(Color(red: 0.05, green: 0.07, blue: 0.15))
    }

    @ViewBuilder
    private var overlayContent: some View {
        switch viewModel.phase {
        case .menu:
            MenuOverlay(viewModel: viewModel)
        case .playing:
            PlayingHUD(viewModel: viewModel)
        case .gameOver:
            GameOverOverlay(viewModel: viewModel)
        }
    }
}

private struct PlayingHUD: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack {
            HStack {
                bestScoreBadge
                Spacer()
                settingsMenu
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            Spacer()
            Text("Tap to flap")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(viewModel.showTutorialHint ? 0.75 : 0))
                .padding(.bottom, 24)
                .accessibilityHidden(!viewModel.showTutorialHint)
        }
    }

    private var bestScoreBadge: some View {
        Text("Best \(viewModel.highScore)")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white.opacity(0.85))
            .accessibilityLabel("Best score \(viewModel.highScore)")
    }

    private var settingsMenu: some View {
        Menu {
            Toggle("Sound", isOn: Binding(
                get: { GameSettings.shared.soundEnabled },
                set: { GameSettings.shared.soundEnabled = $0 }
            ))
            Toggle("Haptics", isOn: Binding(
                get: { GameSettings.shared.hapticsEnabled },
                set: { GameSettings.shared.hapticsEnabled = $0 }
            ))
        } label: {
            Image(systemName: "slider.horizontal.3")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.9))
                .padding(8)
                .background(.white.opacity(0.12), in: Circle())
        }
        .accessibilityLabel("Settings")
    }
}
