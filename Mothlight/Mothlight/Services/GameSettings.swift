import Combine
import Foundation

final class GameSettings: ObservableObject {
    static let shared = GameSettings()

    @Published var soundEnabled: Bool {
        didSet { UserDefaults.standard.set(soundEnabled, forKey: Keys.sound) }
    }

    @Published var hapticsEnabled: Bool {
        didSet { UserDefaults.standard.set(hapticsEnabled, forKey: Keys.haptics) }
    }

    private enum Keys {
        static let sound = "mothlight.sound"
        static let haptics = "mothlight.haptics"
    }

    private init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Keys.sound) == nil {
            soundEnabled = true
        } else {
            soundEnabled = defaults.bool(forKey: Keys.sound)
        }
        if defaults.object(forKey: Keys.haptics) == nil {
            hapticsEnabled = true
        } else {
            hapticsEnabled = defaults.bool(forKey: Keys.haptics)
        }
    }
}
