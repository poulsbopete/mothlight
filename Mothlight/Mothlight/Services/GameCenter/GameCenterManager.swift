import Foundation
import GameKit

enum GameCenterManager {
    static func authenticateIfEnabled() {
        guard GameConfig.enableGameCenter else { return }
        GKLocalPlayer.local.authenticateHandler = { _, _ in }
    }

    static func submitScore(_ score: Int) {
        guard GameConfig.enableGameCenter else { return }
        guard GKLocalPlayer.local.isAuthenticated else { return }
        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: ["mothlight.highscore"],
            completionHandler: { _ in }
        )
    }
}
