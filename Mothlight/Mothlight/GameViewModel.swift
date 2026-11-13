import Combine
import SpriteKit
import SwiftUI
import UIKit

enum GamePhase {
    case menu
    case playing
    case gameOver
}

@MainActor
final class GameViewModel: ObservableObject, MothlightGameSceneDelegate {
    @Published var phase: GamePhase = .menu
    @Published var lastScore = 0
    @Published var highScore: Int
    @Published var showTutorialHint = true
    @Published var canOfferRewardedContinue = false

    let scene: MothlightGameScene

    private weak var rootViewController: UIViewController?
    private var pendingMenuAfterAd = false

    init(size: CGSize) {
        highScore = HighScoreStore.shared.best
        let scene = MothlightGameScene(size: size)
        scene.scaleMode = .resizeFill
        self.scene = scene
        scene.gameDelegate = self
        scene.isPaused = true
    }

    func bindRootViewController(_ controller: UIViewController) {
        rootViewController = controller
    }

    func onAppearBootstrap() {
        scene.isPaused = phase != .playing
        highScore = HighScoreStore.shared.best
        AdCoordinator.shared.bind(purchaseManager: PurchaseManager.shared)
        AppTrackingCoordinator.requestIfNeeded { [weak self] in
            AdCoordinator.shared.configure()
        }
        GameCenterManager.authenticateIfEnabled()
    }

    func startFromMenu() {
        phase = .playing
        scene.isPaused = false
        showTutorialHint = true
        scene.restartRun()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.showTutorialHint = false
        }
    }

    func restartAfterGameOver() {
        showInterstitialIfNeeded { [weak self] in
            self?.startFromMenu()
        }
    }

    func returnToMenu() {
        pendingMenuAfterAd = true
        showInterstitialIfNeeded { [weak self] in
            guard let self else { return }
            self.phase = .menu
            self.pendingMenuAfterAd = false
            self.scene.restartRun()
            self.scene.isPaused = true
        }
    }

    func requestRewardedContinue() {
        guard let rootViewController else {
            phase = .playing
            scene.continueAfterReward()
            return
        }
        AdCoordinator.shared.offerContinue(from: rootViewController) { [weak self] in
            self?.phase = .playing
            self?.scene.continueAfterReward()
        } onDismiss: { }
    }

    private func showInterstitialIfNeeded(then: @escaping () -> Void) {
        guard let rootViewController else {
            then()
            return
        }
        AdCoordinator.shared.recordRunEnded(showInterstitialFrom: rootViewController) {
            then()
        }
    }

    // MARK: - Scene delegate

    func gameSceneDidUpdateScore(_ score: Int) {
        lastScore = score
    }

    func gameSceneDidGameOver(score: Int, canOfferContinue: Bool) {
        lastScore = score
        highScore = HighScoreStore.shared.best
        canOfferRewardedContinue = canOfferContinue
        phase = .gameOver
        GameCenterManager.submitScore(score)
        AdCoordinator.shared.reloadIfNeeded()
    }

    func gameSceneDidContinue() {
        canOfferRewardedContinue = false
    }
}
