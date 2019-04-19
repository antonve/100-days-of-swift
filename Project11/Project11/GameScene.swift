import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        let bouncerLocations = [0, 256, 512, 768, 1024]
        bouncerLocations.forEach { x in
            makeBouncer(at: CGPoint(x: x, y: 0))
        }

        let slotLocations = [128, 384, 640, 896]
        slotLocations.enumerated().forEach { i, x in
            makeSlot(at: CGPoint(x: x, y: 0), isGood: i % 2 == 0)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        let ball = SKSpriteNode(imageNamed: "ballRed")
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
        ball.physicsBody?.restitution = 0.4
        ball.position = location
        addChild(ball)
    }

    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }

    func makeSlot(at position: CGPoint, isGood: Bool) {
        let suffix = isGood ? "Good" : "Bad"

        let slotBase = SKSpriteNode(imageNamed: "slotBase\(suffix)")
        slotBase.position = position
        addChild(slotBase)

        let slotGlow = SKSpriteNode(imageNamed: "slotGlow\(suffix)")
        slotGlow.position = position
        addChild(slotGlow)

        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
}
