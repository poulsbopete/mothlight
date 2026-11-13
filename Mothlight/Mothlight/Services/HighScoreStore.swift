import Foundation

final class HighScoreStore {
    static let shared = HighScoreStore()

    private let key = "mothlight.highscore"

    var best: Int {
        UserDefaults.standard.integer(forKey: key)
    }

    func register(score: Int) {
        guard score > best else { return }
        UserDefaults.standard.set(score, forKey: key)
    }
}
