import Foundation
import UIKit

/// Abstraction over ad networks — production uses AdMob; simulator/previews can use mocks.
protocol AdServing: AnyObject {
    func configure()
    func loadAds()
    func showInterstitial(from root: UIViewController, completion: @escaping () -> Void)
    func showRewarded(from root: UIViewController, onReward: @escaping () -> Void, onDismiss: @escaping () -> Void)
    var isRewardedReady: Bool { get }
    var isInterstitialReady: Bool { get }
}

final class AdCoordinator: ObservableObject {
    static let shared = AdCoordinator()

    private var service: AdServing
    private(set) var runsSinceLastInterstitial = 0

    @Published private(set) var adsRemoved: Bool = false

    private init() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            service = PreviewAdService()
        } else {
            service = AdMobAdService()
        }
    }

    func bind(purchaseManager: PurchaseManager) {
        adsRemoved = purchaseManager.hasRemovedAds
    }

    func setAdsRemoved(_ removed: Bool) {
        adsRemoved = removed
    }

    func configure() {
        guard !adsRemoved else { return }
        service.configure()
        service.loadAds()
    }

    func reloadIfNeeded() {
        guard !adsRemoved else { return }
        service.loadAds()
    }

    func recordRunEnded(showInterstitialFrom root: UIViewController, completion: @escaping () -> Void) {
        guard !adsRemoved else {
            completion()
            return
        }
        runsSinceLastInterstitial += 1
        guard runsSinceLastInterstitial >= GameConfig.runsBetweenInterstitials,
              service.isInterstitialReady
        else {
            completion()
            return
        }
        runsSinceLastInterstitial = 0
        service.showInterstitial(from: root) { [weak self] in
            self?.service.loadAds()
            completion()
        }
    }

    func offerContinue(from root: UIViewController, onReward: @escaping () -> Void, onDismiss: @escaping () -> Void) {
        guard !adsRemoved else {
            onDismiss()
            return
        }
        guard service.isRewardedReady else {
            onDismiss()
            return
        }
        service.showRewarded(from: root, onReward: onReward, onDismiss: onDismiss)
    }

    var canShowRewardedContinue: Bool {
        !adsRemoved && service.isRewardedReady
    }
}
