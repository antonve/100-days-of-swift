import SpriteKit

class GameScene: SKScene {
    let scoreLabel: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "Score: 0"
        label.horizontalAlignmentMode = .right
        label.position = CGPoint(x: 980, y: 700)
        return label
    }()

    let editLabel: SKLabelNode = {
       let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "Edit"
        label.position = CGPoint(x: 80, y: 700)
        return label
    }()

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }

    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

        addChild(scoreLabel)
        addChild(editLabel)

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self

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

        let objects = nodes(at: location)

        if objects.contains(editLabel) {
            editingMode.toggle()
            return
        }

        createBall(at: location)
    }

    func createBall(at position: CGPoint) {
        let ball = SKSpriteNode(imageNamed: "ballRed")
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
        ball.physicsBody?.restitution = 0.4
        ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
        ball.position = position
        ball.name = "ball"
        addChild(ball)
    }

    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        bouncer.zPosition = 2
        addChild(bouncer)
    }

    func makeSlot(at position: CGPoint, isGood: Bool) {
        let slotType = isGood ? "Good" : "Bad"

        let slotBase = SKSpriteNode(imageNamed: "slotBase\(slotType)")
        slotBase.position = position
        slotBase.name = slotType.lowercased()
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        slotBase.zPosition = 1
        addChild(slotBase)

        let slotGlow = SKSpriteNode(imageNamed: "slotGlow\(slotType)")
        slotGlow.position = position
        slotGlow.zPosition = 1
        addChild(slotGlow)

        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        switch (nodeA.name, nodeB.name) {
        case ("ball", "ball"):
            return
        case ("ball", _):
            collision(between: nodeA, object: nodeB)
        case (_, "ball"):
            collision(between: nodeB, object: nodeA)
        default:
            return
        }
    }

    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        }
    }

    func destroy(ball: SKNode) {
        ball.removeFromParent()
    }
}
