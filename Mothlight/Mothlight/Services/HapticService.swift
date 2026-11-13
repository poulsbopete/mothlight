import UIKit

final class HapticService {
    static let shared = HapticService()

    private let light = UIImpactFeedbackGenerator(style: .light)
    private let soft = UIImpactFeedbackGenerator(style: .soft)
    private let notification = UINotificationFeedbackGenerator()

    private init() {
        light.prepare()
        soft.prepare()
        notification.prepare()
    }

    private var enabled: Bool { GameSettings.shared.hapticsEnabled }

    func lightTap() {
        guard enabled else { return }
        light.impactOccurred()
    }

    func softTap() {
        guard enabled else { return }
        soft.impactOccurred()
    }

    func success() {
        guard enabled else { return }
        notification.notificationOccurred(.success)
    }

    func error() {
        guard enabled else { return }
        notification.notificationOccurred(.error)
    }
}
