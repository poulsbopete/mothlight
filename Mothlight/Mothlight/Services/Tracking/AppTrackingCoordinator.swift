import AppTrackingTransparency
import AdSupport
import Foundation

enum AppTrackingCoordinator {
    private static let askedKey = "mothlight.att.asked"

    static func requestIfNeeded(completion: (() -> Void)? = nil) {
        guard #available(iOS 14, *) else {
            completion?()
            return
        }
        let status = ATTrackingManager.trackingAuthorizationStatus
        guard status == .notDetermined else {
            completion?()
            return
        }
        guard !UserDefaults.standard.bool(forKey: askedKey) else {
            completion?()
            return
        }
        ATTrackingManager.requestTrackingAuthorization { _ in
            UserDefaults.standard.set(true, forKey: askedKey)
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
}
