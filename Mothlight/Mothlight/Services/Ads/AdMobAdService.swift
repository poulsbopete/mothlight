import Foundation
import GoogleMobileAds
import UIKit

final class AdMobAdService: NSObject, AdServing {
    private var interstitial: InterstitialAd?
    private var rewarded: RewardedAd?

    private(set) var isInterstitialReady = false
    private(set) var isRewardedReady = false

    private var interstitialCompletion: (() -> Void)?
    private var rewardedOnReward: (() -> Void)?
    private var rewardedOnDismiss: (() -> Void)?

    func configure() {
        MobileAds.shared.start()
    }

    func loadAds() {
        loadInterstitial()
        loadRewarded()
    }

    private func loadInterstitial() {
        InterstitialAd.load(
            with: GameConfig.admobInterstitialUnitID,
            request: Request()
        ) { [weak self] ad, error in
            guard let self else { return }
            if error != nil {
                self.isInterstitialReady = false
                return
            }
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
            self.isInterstitialReady = ad != nil
        }
    }

    private func loadRewarded() {
        RewardedAd.load(
            with: GameConfig.admobRewardedUnitID,
            request: Request()
        ) { [weak self] ad, error in
            guard let self else { return }
            if error != nil {
                self.isRewardedReady = false
                return
            }
            self.rewarded = ad
            self.rewarded?.fullScreenContentDelegate = self
            self.isRewardedReady = ad != nil
        }
    }

    func showInterstitial(from root: UIViewController, completion: @escaping () -> Void) {
        guard let interstitial else {
            completion()
            return
        }
        interstitialCompletion = completion
        interstitial.present(from: root)
    }

    func showRewarded(from root: UIViewController, onReward: @escaping () -> Void, onDismiss: @escaping () -> Void) {
        guard let rewarded else {
            onDismiss()
            return
        }
        rewardedOnReward = onReward
        rewardedOnDismiss = onDismiss
        rewarded.present(from: root) { [weak self] in
            self?.rewardedOnReward?()
        }
    }
}

extension AdMobAdService: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        if ad is InterstitialAd {
            interstitialCompletion?()
            interstitialCompletion = nil
            isInterstitialReady = false
            loadInterstitial()
        } else if ad is RewardedAd {
            rewardedOnDismiss?()
            rewardedOnReward = nil
            rewardedOnDismiss = nil
            isRewardedReady = false
            loadRewarded()
        }
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        if ad is InterstitialAd {
            interstitialCompletion?()
            interstitialCompletion = nil
        } else if ad is RewardedAd {
            rewardedOnDismiss?()
            rewardedOnReward = nil
            rewardedOnDismiss = nil
        }
    }
}
