import CoreGraphics
import Foundation

enum GameConfig {
    static let enableGameCenter = false

    static let removeAdsProductID = "com.mothlight.removeads"

    /// Replace with your AdMob app ID before release (test ID below is Google's sample).
    static let admobAppID = "ca-app-pub-3940256099942544~1458002511"
    static let admobInterstitialUnitID = "ca-app-pub-3940256099942544/4411468910"
    static let admobRewardedUnitID = "ca-app-pub-3940256099942544/1712485313"

    static let runsBetweenInterstitials = 3

    static let mothFixedXRatio: CGFloat = 0.28
    static let flapImpulse: CGFloat = 420
    static let gravity: CGFloat = -28
    static let maxFallSpeed: CGFloat = -520
    static let maxRiseSpeed: CGFloat = 380

    static let gapHeightBase: CGFloat = 200
    static let gapHeightMin: CGFloat = 138
    static let obstacleSpacing: CGFloat = 92
    static let obstacleWidth: CGFloat = 64
    static let scrollSpeedBase: CGFloat = 195
    static let scrollSpeedMax: CGFloat = 340
}
