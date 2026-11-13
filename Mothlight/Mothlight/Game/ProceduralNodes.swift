import SpriteKit
import UIKit

enum ProceduralArt {
    static func makeMothNode(scale: CGFloat = 1) -> SKNode {
        let container = SKNode()
        container.setScale(scale)

        let wingColor = SKColor(red: 0.75, green: 0.92, blue: 0.55, alpha: 0.85)
        let wingGlow = SKColor(red: 0.9, green: 1.0, blue: 0.7, alpha: 0.35)

        for side in [-1.0, 1.0] {
            let wing = SKShapeNode(ellipseOf: CGSize(width: 44, height: 28))
            wing.fillColor = wingColor
            wing.strokeColor = SKColor(white: 1, alpha: 0.25)
            wing.lineWidth = 1.5
            wing.position = CGPoint(x: CGFloat(side) * 18, y: 4)
            wing.zRotation = CGFloat(side) * 0.15
            container.addChild(wing)

            let glow = SKShapeNode(ellipseOf: CGSize(width: 50, height: 34))
            glow.fillColor = wingGlow
            glow.strokeColor = .clear
            glow.position = wing.position
            glow.zPosition = -1
            container.addChild(glow)
        }

        let body = SKShapeNode(ellipseOf: CGSize(width: 14, height: 22))
        body.fillColor = SKColor(white: 0.92, alpha: 1)
        body.strokeColor = SKColor(white: 0.7, alpha: 0.5)
        body.lineWidth = 1
        container.addChild(body)

        let antennaL = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -3, y: 10))
        path.addQuadCurve(to: CGPoint(x: -8, y: 18), control: CGPoint(x: -10, y: 12))
        antennaL.path = path
        antennaL.strokeColor = SKColor(white: 0.85, alpha: 1)
        antennaL.lineWidth = 1.2
        container.addChild(antennaL)

        let antennaR = SKShapeNode()
        let pathR = CGMutablePath()
        pathR.move(to: CGPoint(x: 3, y: 10))
        pathR.addQuadCurve(to: CGPoint(x: 8, y: 18), control: CGPoint(x: 10, y: 12))
        antennaR.path = pathR
        antennaR.strokeColor = SKColor(white: 0.85, alpha: 1)
        antennaR.lineWidth = 1.2
        container.addChild(antennaR)

        let eye = SKShapeNode(circleOfRadius: 2.2)
        eye.fillColor = SKColor(red: 0.2, green: 0.25, blue: 0.35, alpha: 1)
        eye.strokeColor = .clear
        eye.position = CGPoint(x: 0, y: 6)
        container.addChild(eye)

        return container
    }

    static func makeTreeTrunk(width: CGFloat, height: CGFloat) -> SKNode {
        let node = SKNode()
        let trunk = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 6)
        trunk.fillColor = SKColor(red: 0.22, green: 0.16, blue: 0.12, alpha: 1)
        trunk.strokeColor = SKColor(red: 0.35, green: 0.26, blue: 0.18, alpha: 0.6)
        trunk.lineWidth = 2
        node.addChild(trunk)

        let highlight = SKShapeNode(rectOf: CGSize(width: width * 0.15, height: height), cornerRadius: 2)
        highlight.fillColor = SKColor(white: 1, alpha: 0.08)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: -width * 0.25, y: 0)
        node.addChild(highlight)

        return node
    }

    static func makeMoonbeam() -> SKNode {
        let star = SKShapeNode(circleOfRadius: 10)
        star.fillColor = SKColor(red: 1.0, green: 0.95, blue: 0.6, alpha: 0.9)
        star.strokeColor = SKColor(red: 1.0, green: 0.98, blue: 0.8, alpha: 0.5)
        star.lineWidth = 2
        star.glowWidth = 4

        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.6),
            SKAction.scale(to: 0.95, duration: 0.6),
        ])
        star.run(SKAction.repeatForever(pulse))
        return star
    }

    static func applyNightBackground(to scene: SKScene) {
        scene.backgroundColor = SKColor(red: 0.06, green: 0.08, blue: 0.18, alpha: 1)

        let gradientHeight = scene.size.height
        let steps = 8
        for i in 0..<steps {
            let strip = SKShapeNode(rectOf: CGSize(width: scene.size.width + 4, height: gradientHeight / CGFloat(steps) + 2))
            let t = CGFloat(i) / CGFloat(steps - 1)
            strip.fillColor = SKColor(
                red: 0.05 + t * 0.04,
                green: 0.07 + t * 0.06,
                blue: 0.15 + t * 0.12,
                alpha: 1
            )
            strip.strokeColor = .clear
            strip.position = CGPoint(
                x: scene.size.width / 2,
                y: CGFloat(i) * (gradientHeight / CGFloat(steps)) + gradientHeight / CGFloat(steps) / 2
            )
            strip.zPosition = -100
            scene.addChild(strip)
        }

        let moon = SKShapeNode(circleOfRadius: 36)
        moon.fillColor = SKColor(red: 0.98, green: 0.94, blue: 0.78, alpha: 0.85)
        moon.strokeColor = .clear
        moon.position = CGPoint(x: scene.size.width * 0.82, y: scene.size.height * 0.78)
        moon.zPosition = -90
        scene.addChild(moon)

        for i in 0..<18 {
            let speck = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.8...1.6))
            speck.fillColor = SKColor(white: 1, alpha: CGFloat.random(in: 0.15...0.45))
            speck.strokeColor = .clear
            speck.position = CGPoint(
                x: CGFloat.random(in: 0...scene.size.width),
                y: CGFloat.random(in: scene.size.height * 0.35...scene.size.height)
            )
            speck.zPosition = -95
            scene.addChild(speck)
        }
    }
}
