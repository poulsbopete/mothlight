import SpriteKit
import UIKit

protocol MothlightGameSceneDelegate: AnyObject {
    func gameSceneDidUpdateScore(_ score: Int)
    func gameSceneDidGameOver(score: Int, canOfferContinue: Bool)
    func gameSceneDidContinue()
}

final class MothlightGameScene: SKScene, SKPhysicsContactDelegate {
    weak var gameDelegate: MothlightGameSceneDelegate?

    private var moth: SKNode!
    private var mothBody: SKPhysicsBody!
    private var score = 0
    private var isRunning = false
    private var isDead = false
    private var usedContinue = false
    private var lastGapCenterY: CGFloat = 0
    private var scrollSpeed: CGFloat = GameConfig.scrollSpeedBase
    private var nextSpawnX: CGFloat = 0
    private var scoredObstacleIDs = Set<ObjectIdentifier>()

    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private var wingTimer: TimeInterval = 0

    private struct Physics {
        static let moth: UInt32 = 1 << 0
        static let obstacle: UInt32 = 1 << 1
        static let collectible: UInt32 = 1 << 2
        static let boundary: UInt32 = 1 << 3
    }

    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: GameConfig.gravity)
        physicsWorld.contactDelegate = self
        view.isMultipleTouchEnabled = false

        ProceduralArt.applyNightBackground(to: self)
        setupBoundaries()
        setupMoth()
        setupHUD()
        resetRunState()
    }

  private func setupBoundaries() {
        let floor = SKNode()
        floor.position = CGPoint(x: size.width / 2, y: -20)
        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 2, height: 40))
        floor.physicsBody?.isDynamic = false
        floor.physicsBody?.categoryBitMask = Physics.boundary
        floor.physicsBody?.contactTestBitMask = Physics.moth
        addChild(floor)

        let ceiling = SKNode()
        ceiling.position = CGPoint(x: size.width / 2, y: size.height + 20)
        ceiling.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 2, height: 40))
        ceiling.physicsBody?.isDynamic = false
        ceiling.physicsBody?.categoryBitMask = Physics.boundary
        ceiling.physicsBody?.contactTestBitMask = Physics.moth
        addChild(ceiling)
    }

    private func setupMoth() {
        moth = ProceduralArt.makeMothNode(scale: 1.1)
        moth.position = CGPoint(x: size.width * GameConfig.mothFixedXRatio, y: size.height * 0.55)
        addChild(moth)

        let bodySize = CGSize(width: 22, height: 18)
        mothBody = SKPhysicsBody(rectangleOf: bodySize)
        mothBody.mass = 0.12
        mothBody.allowsRotation = false
        mothBody.linearDamping = 0.2
        mothBody.restitution = 0
        mothBody.categoryBitMask = Physics.moth
        mothBody.contactTestBitMask = Physics.obstacle | Physics.boundary | Physics.collectible
        mothBody.collisionBitMask = Physics.obstacle | Physics.boundary
        moth.physicsBody = mothBody
    }

    private func setupHUD() {
        scoreLabel.fontSize = 34
        scoreLabel.fontColor = SKColor(white: 1, alpha: 0.92)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 56)
        scoreLabel.zPosition = 50
        addChild(scoreLabel)
        updateScoreLabel()
    }

    func startGame() {
        guard !isRunning else { return }
        isRunning = true
        isDead = false
        HapticService.shared.lightTap()
        SoundEngine.shared.playFlap()
    }

    func restartRun() {
        removeAllChildren()
        ProceduralArt.applyNightBackground(to: self)
        setupBoundaries()
        setupMoth()
        setupHUD()
        resetRunState()
        startGame()
    }

    func continueAfterReward() {
        isDead = false
        usedContinue = true
        moth.physicsBody?.velocity = .zero
        moth.position.y = min(size.height * 0.7, moth.position.y + 80)
        clearNearbyObstacles()
        gameDelegate?.gameSceneDidContinue()
        isRunning = true
    }

    private func resetRunState() {
        score = 0
        usedContinue = false
        scoredObstacleIDs.removeAll()
        scrollSpeed = GameConfig.scrollSpeedBase
        lastGapCenterY = size.height * 0.5
        nextSpawnX = size.width + 80
        updateScoreLabel()
        spawnInitialObstacles()
        isRunning = false
    }

    private func spawnInitialObstacles() {
        var x = size.width + 40
        for _ in 0..<4 {
            spawnObstaclePair(atX: x)
            x += GameConfig.obstacleSpacing * 3.2
        }
        nextSpawnX = x
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isDead else { return }
        if !isRunning {
            startGame()
        }
        flap()
    }

    private func flap() {
        guard isRunning else { return }
        var velocity = mothBody.velocity
        velocity.dy = min(velocity.dy + GameConfig.flapImpulse * 0.35, GameConfig.maxRiseSpeed)
        mothBody.velocity = velocity
        HapticService.shared.softTap()
        SoundEngine.shared.playFlap()
        runMothTilt(up: true)
    }

    private func runMothTilt(up: Bool) {
        let angle: CGFloat = up ? 0.35 : -0.55
        moth.run(SKAction.rotate(toAngle: angle, duration: 0.12, shortenUnitArc: true))
    }

    override func update(_ currentTime: TimeInterval) {
        guard isRunning, !isDead else { return }

        wingTimer += 1 / 60.0
        if wingTimer > 0.08 {
            wingTimer = 0
            let wobble = SKAction.sequence([
                SKAction.scaleX(to: 0.92, duration: 0.06),
                SKAction.scaleX(to: 1.0, duration: 0.06),
            ])
            moth.run(wobble)
        }

        if moth.position.x != size.width * GameConfig.mothFixedXRatio {
            moth.position.x = size.width * GameConfig.mothFixedXRatio
        }

        if mothBody.velocity.dy < GameConfig.maxFallSpeed {
            mothBody.velocity.dy = GameConfig.maxFallSpeed
        }
        runMothTilt(up: mothBody.velocity.dy > -80)

        scrollObstacles()
        maybeSpawnObstacle()
    }

    private func scrollObstacles() {
        let dx = scrollSpeed * (1.0 / 60.0)
        for node in children where node.name == "obstaclePair" || node.name == "moonbeam" {
            node.position.x -= dx
            if let pair = node as? ObstaclePairNode, pair.position.x < -120 {
                pair.removeFromParent()
            } else if node.name == "moonbeam", node.position.x < -40 {
                node.removeFromParent()
            }
        }
    }

    private func maybeSpawnObstacle() {
        let rightmost = children.compactMap { $0 as? ObstaclePairNode }.map(\.position.x).max() ?? 0
        if rightmost < size.width - GameConfig.obstacleSpacing * 2 {
            spawnObstaclePair(atX: max(nextSpawnX, size.width + 40))
            nextSpawnX += GameConfig.obstacleSpacing * 3.2
            if Bool.random() && score > 2 {
                spawnMoonbeam(nearX: nextSpawnX - GameConfig.obstacleSpacing * 1.6)
            }
        }
    }

    private func gapHeight(forScore score: Int) -> CGFloat {
        let shrink = CGFloat(min(score, 45)) * 1.4
        return max(GameConfig.gapHeightMin, GameConfig.gapHeightBase - shrink)
    }

    private func spawnObstaclePair(atX x: CGFloat) {
        let gap = gapHeight(forScore: score)
        let delta = CGFloat.random(in: -110...110)
        var centerY = lastGapCenterY + delta
        let margin = gap / 2 + 70
        centerY = max(margin, min(size.height - margin, centerY))
        lastGapCenterY = centerY

        let pair = ObstaclePairNode(
            gapCenterY: centerY,
            gapHeight: gap,
            width: GameConfig.obstacleWidth,
            sceneHeight: size.height
        )
        pair.position = CGPoint(x: x, y: 0)
        pair.name = "obstaclePair"
        addChild(pair)
    }

    private func spawnMoonbeam(nearX x: CGFloat) {
        let beam = ProceduralArt.makeMoonbeam()
        beam.name = "moonbeam"
        beam.position = CGPoint(x: x, y: lastGapCenterY + CGFloat.random(in: -30...30))
        beam.physicsBody = SKPhysicsBody(circleOfRadius: 12)
        beam.physicsBody?.isDynamic = false
        beam.physicsBody?.categoryBitMask = Physics.collectible
        beam.physicsBody?.contactTestBitMask = Physics.moth
        beam.physicsBody?.collisionBitMask = 0
        addChild(beam)
    }

    private func clearNearbyObstacles() {
        for node in children where node.name == "obstaclePair" {
            if node.position.x < size.width * 0.65 {
                node.removeFromParent()
            }
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard !isDead else { return }
        let masks = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if masks & Physics.collectible != 0 {
            handleCollectible(contact)
            return
        }

        if masks & (Physics.obstacle | Physics.boundary) != 0 {
            triggerGameOver()
        }
    }

    private func handleCollectible(_ contact: SKPhysicsContact) {
        let collectibleBody = contact.bodyA.categoryBitMask == Physics.collectible ? contact.bodyA : contact.bodyB
        guard let node = collectibleBody.node, node.name == "moonbeam" else { return }
        node.removeFromParent()
        score += 3
        updateScoreLabel()
        gameDelegate?.gameSceneDidUpdateScore(score)
        HapticService.shared.success()
        SoundEngine.shared.playChime()
    }

    private func registerObstaclePassed(_ pair: ObstaclePairNode) {
        let id = ObjectIdentifier(pair)
        guard !scoredObstacleIDs.contains(id) else { return }
        if pair.position.x + GameConfig.obstacleWidth < moth.position.x {
            scoredObstacleIDs.insert(id)
            score += 1
            updateScoreLabel()
            gameDelegate?.gameSceneDidUpdateScore(score)
            scrollSpeed = min(
                GameConfig.scrollSpeedMax,
                GameConfig.scrollSpeedBase + CGFloat(score) * 4.2
            )
            SoundEngine.shared.playPass()
        }
    }

    private func triggerGameOver() {
        isDead = true
        isRunning = false
        moth.physicsBody?.velocity = .zero
        HapticService.shared.error()
        SoundEngine.shared.playThud()
        HighScoreStore.shared.register(score: score)
        let canContinue = !usedContinue
        gameDelegate?.gameSceneDidGameOver(score: score, canOfferContinue: canContinue)
    }

    private func updateScoreLabel() {
        scoreLabel.text = "\(score)"
    }

    override func didEvaluateActions() {
        for case let pair as ObstaclePairNode in children {
            registerObstaclePassed(pair)
        }
    }
}

// MARK: - Obstacle pair

final class ObstaclePairNode: SKNode {
    private let gapCenterY: CGFloat
    private let gapHeight: CGFloat

    init(gapCenterY: CGFloat, gapHeight: CGFloat, width: CGFloat, sceneHeight: CGFloat) {
        self.gapCenterY = gapCenterY
        self.gapHeight = gapHeight
        super.init()

        let lowerHeight = max(gapCenterY - gapHeight / 2, 0)
        let upperHeight = max(sceneHeight - (gapCenterY + gapHeight / 2), 0)

        if lowerHeight > 1 {
            let lower = ProceduralArt.makeTreeTrunk(width: width, height: lowerHeight)
            lower.position = CGPoint(x: 0, y: lowerHeight / 2)
            attachObstaclePhysics(to: lower, size: CGSize(width: width, height: lowerHeight))
            addChild(lower)
        }

        if upperHeight > 1 {
            let upper = ProceduralArt.makeTreeTrunk(width: width, height: upperHeight)
            upper.position = CGPoint(x: 0, y: gapCenterY + gapHeight / 2 + upperHeight / 2)
            attachObstaclePhysics(to: upper, size: CGSize(width: width, height: upperHeight))
            addChild(upper)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    private func attachObstaclePhysics(to node: SKNode, size: CGSize) {
        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = false
        body.categoryBitMask = 1 << 1
        body.contactTestBitMask = 1 << 0
        body.collisionBitMask = 1 << 0
        node.physicsBody = body
    }
}
