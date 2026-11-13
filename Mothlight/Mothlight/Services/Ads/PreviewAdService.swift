import Foundation
import UIKit

/// Stand-in ads for Simulator and SwiftUI previews — no SDK call required.
final class PreviewAdService: AdServing {
    private(set) var isInterstitialReady = true
    private(set) var isRewardedReady = true

    func configure() {}

    func loadAds() {
        isInterstitialReady = true
        isRewardedReady = true
    }

    func showInterstitial(from root: UIViewController, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Test Interstitial",
            message: "A real build shows Google test interstitials here.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Close", style: .default) { _ in completion() })
        root.present(alert, animated: true)
    }

    func showRewarded(from root: UIViewController, onReward: @escaping () -> Void, onDismiss: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Test Rewarded Ad",
            message: "Tap reward to simulate continuing your run.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Give reward", style: .default) { _ in
            onReward()
            onDismiss()
        })
        alert.addAction(UIAlertAction(title: "Skip", style: .cancel) { _ in onDismiss() })
        root.present(alert, animated: true)
    }
}
