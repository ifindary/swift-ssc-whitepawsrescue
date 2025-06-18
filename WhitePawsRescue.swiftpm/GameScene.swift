//
//  GameScene.swift
//  White Paws Rescue
//
//  Created by 선애 on 2/15/25.
//
// Game Logic

import SwiftUI
import SpriteKit

class GameScene: SKScene {
    private var snowLeopard: SKSpriteNode?
    private var isMovingRight = true
    private var hunger: Float = 3.0
    private var score: Int = 0
    private var frameCount: Int = 0
    private let scoreUpdateFrames: Int = 3
    
    // category masks
    private let snowLeopardCategory: UInt32 = 1
    private let obstacleCategory: UInt32 = 2
    private let foodCategory: UInt32 = 4
    
    // Timer
    private var lastUpdateTime: TimeInterval = 0
    private var timeSinceLastObstacleSpawn: TimeInterval = 0
    private var timeSinceLastFoodSpawn: TimeInterval = 0
    
    // textures
    private var snowLeopardTextures: [SKTexture] = []
    private var rockTextures: [SKTexture] = []
    private var trapTextures: [SKTexture] = []
    private var trashPileTextures: [SKTexture] = []
    private var meatTextures: [SKTexture] = []
    private var mountainTexture: SKTexture?
    private var snowLineTextures: [SKTexture] = []
    
    // background
    private var mountainBackground1: SKSpriteNode?
    private var mountainBackground2: SKSpriteNode?
    private var snowLine: SKSpriteNode?
    
    // key constant
    let gameClearScore = 1000
    let hungerDecrease: Float = 0.001
    let obstableRespawnTime: TimeInterval = 1.8
    let foodRespawnTime: TimeInterval = 8.0
    let mountainScrollSpeed: CGFloat = 8.0
    
    // weak var gameDelegate: GamePlayDelegate?
    var gameDelegate: GamePlayDelegate?
    
    //
    // init setting
    //
    override func didMove(to view: SKView) {
        // must load texture first
        loadTextures()
        setupMountain()
        setupSnowLine()
        
        setupGame()
    }
    
    private func loadTextures() {
        let textures = Textures()
        snowLeopardTextures = textures.snowLeopard
        rockTextures = textures.rock
        trapTextures = textures.trap
        trashPileTextures = textures.trashPile
        meatTextures = textures.meat
        mountainTexture = textures.meltingMountain
        snowLineTextures = textures.snowLine
    }
    
    private func setupMountain() {
        let backgroundWidth = frame.width
        let backgroundHeight = frame.height * 1.5
        
        mountainBackground1 = SKSpriteNode(texture: mountainTexture, size: CGSize(width: backgroundWidth, height: backgroundHeight))
        mountainBackground2 = SKSpriteNode(texture: mountainTexture, size: CGSize(width: backgroundWidth, height: backgroundHeight))
        
        if let mountainBackground1 = mountainBackground1, let mountainBackground2 = mountainBackground2 {
            mountainBackground1.position = CGPoint(x: frame.midX, y: frame.midY)
            mountainBackground1.zPosition = -10 // lowest
            
            mountainBackground2.position = CGPoint(x: frame.midX, y: mountainBackground1.position.y + backgroundHeight)
            mountainBackground2.zPosition = -10
            
            addChild(mountainBackground1)
            addChild(mountainBackground2)
        }
    }
    
    // effect of showing the snow is melting
    private func setupSnowLine() {
        let snowLineWidth = frame.width
        let snowLineHeight = frame.width * 0.25
        
        snowLine = SKSpriteNode(texture: snowLineTextures[0], size: CGSize(width: snowLineWidth, height: snowLineHeight))
        
        if let snowLine = snowLine {
            snowLine.position = CGPoint(x: frame.midX, y: frame.height - snowLineHeight/2)
            snowLine.zPosition = 10 // highest
            
            let animateAction = SKAction.animate(with: snowLineTextures, timePerFrame: 0.3, resize: false, restore: true)
            let repeatAction = SKAction.repeatForever(animateAction)
            
            snowLine.run(repeatAction)
            
            addChild(snowLine)
        }
    }
    
    private func setupGame() {
        physicsWorld.contactDelegate = self // physical conflict detection
        physicsWorld.gravity = .zero // gravity deactivation
        
//        backgroundColor = .gray
        
        let snowLeopardSize = CGSize(width: frame.width * 0.22, height: frame.width * 0.22)
        
           if !snowLeopardTextures.isEmpty {
               snowLeopard = SKSpriteNode(texture: snowLeopardTextures[0], size: snowLeopardSize)
               
               // SKAction.animate를 사용한 애니메이션 설정
               let animateAction = SKAction.animate(with: snowLeopardTextures,
                                                   timePerFrame: 0.2,
                                                   resize: false,
                                                   restore: true)
               let repeatAction = SKAction.repeatForever(animateAction)
               
               snowLeopard?.run(repeatAction)
           } else {
               snowLeopard = SKSpriteNode(color: .white, size: snowLeopardSize)
           }
    
        if let snowLeopard = snowLeopard {
            snowLeopard.position = CGPoint(x: frame.midX, y: frame.midY * 0.5)
            
            // set box size considering texture shape
            let collisionBoxWidth = snowLeopardSize.width * 0.5
            let collisionBoxHeight = snowLeopardSize.height * 0.8
            let collisionBoxSize = CGSize(width: collisionBoxWidth, height: collisionBoxHeight)
            
            snowLeopard.physicsBody = SKPhysicsBody(rectangleOf: collisionBoxSize)
            snowLeopard.physicsBody?.isDynamic = true
            snowLeopard.physicsBody?.categoryBitMask = snowLeopardCategory
            snowLeopard.physicsBody?.contactTestBitMask = obstacleCategory | foodCategory
            snowLeopard.physicsBody?.collisionBitMask = 0
            
            addChild(snowLeopard)
        }
    }
    
    // tap -> rotate direction
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isMovingRight = !isMovingRight
        
        if let leopard = snowLeopard {
            // must follow the steps (make the size bigger -> restore the origin size -> change the direction)
            // otherwise, the size or direction changes strangely
            leopard.setScale(1.1)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                leopard.setScale(1.0)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    if self.isMovingRight {
                        leopard.xScale = 1.0 // right
                    } else {
                        leopard.xScale = -1.0 // left
                    }
                }
            }
        }
    }
    
    //
    // update in game play
    //
    override func update(_ currentTime: TimeInterval) {
        updateBackground()
        moveSnowLeopard()
        updatehunger()
        checkGameStatus()
        
        // update the current state for ui
        Task { @MainActor in
            gameDelegate?.updateGameState(score: score, hunger: hunger)
        }
        
        
        // spawn obstacles and food
        //
        
        // if the first frame
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        timeSinceLastObstacleSpawn += dt
        timeSinceLastFoodSpawn += dt
        
        // 장애물 생성
        if timeSinceLastObstacleSpawn > obstableRespawnTime {
//            spawnObstacle()
            let obstacleType = Int.random(in: 1...3)
            
            switch obstacleType {
            case 1: // rock
                spawnRock()
            case 2: // trap
                spawnTrap()
            case 3: // trash
                spawnTrashPile()
            default:
                spawnTrap()
            }
            
            timeSinceLastObstacleSpawn = 0
        }
        
        if timeSinceLastFoodSpawn > foodRespawnTime {
            spawnFood()
            timeSinceLastFoodSpawn = 0
        }
    }
    
    private func updateBackground() {
        guard let mountainBackground1 = mountainBackground1,
              let mountainBackground2 = mountainBackground2 else {
            return
        }
        
        // repeating two images to show the background continuously
        // 1 -> 2 -> 1 -> 2 -> 1 -> ...
        mountainBackground1.position.y -= mountainScrollSpeed
        mountainBackground2.position.y -= mountainScrollSpeed
        
        if mountainBackground1.position.y < -mountainBackground1.size.height/2 {
            mountainBackground1.position.y = mountainBackground2.position.y + mountainBackground2.size.height
        }
        
        if mountainBackground2.position.y < -mountainBackground2.size.height/2 {
            mountainBackground2.position.y = mountainBackground1.position.y + mountainBackground1.size.height
        }
    }
    
    private func moveSnowLeopard() {
        guard let snowLeopard = snowLeopard else { return }
        
        let moveAmount: CGFloat = 6.0
        let movement = isMovingRight ? moveAmount : -moveAmount
        
        snowLeopard.position.x += movement
        
        snowLeopard.xScale = isMovingRight ? abs(snowLeopard.xScale) : -abs(snowLeopard.xScale)
        
        // if the snow leopard hit the wall
        // rotate the direction automatically AND reduce hunger
        if snowLeopard.position.x <= snowLeopard.size.width / 2 || snowLeopard.position.x >= frame.width - snowLeopard.size.width / 2 {
            isMovingRight.toggle()
            hunger -= 1
            
            let originalColor = snowLeopard.color
            
            let blinkAction = SKAction.sequence([
                SKAction.group([
                    SKAction.colorize(with: .red, colorBlendFactor: 0.7, duration: 0.1),
                    SKAction.fadeAlpha(to: 0.5, duration: 0.1)
                ]),
                SKAction.group([
                    SKAction.colorize(with: originalColor, colorBlendFactor: 0, duration: 0.1),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.1)
                ])
            ])
            snowLeopard.run(SKAction.repeat(blinkAction, count: 1))
        }
    }
    
    // hunger decreases automatically
    // reflection of real problems
    private func updatehunger() {
        hunger -= hungerDecrease
    }
    
    // spawn obstacles
    // rock : move faster
    // trap : nothing special
    // trash : bigger
    
    // separate functions to vary the characteristics between obstacles
//    private func spawnObstacle() {
//        // Ramdon Selection
//        let obstacleType = Int.random(in: 1...3)
//        var obstacleTextures : [SKTexture]
//
//        // set type
//        switch obstacleType {
//            case 1: // rock
//                obstacleTextures = rockTextures
//            case 2: // trap
//                obstacleTextures = trapTextures
//            case 3: // trash
//                obstacleTextures = trashTextures
//            default:
//                obstacleTextures = rockTextures
//        }
//
//        // set size
//        let obstacleWidth = frame.width * 0.2
//        let obstacleHeight = frame.width * 0.2
//        let obstacleSize = CGSize(width: obstacleWidth, height: obstacleHeight)
//
//        // set position
//        // 5% excluded from both ends (because walls are a kind of obstacle)
//        let safeMargin: CGFloat = frame.width * 0.05
//        let randomX = CGFloat.random(in: safeMargin...(frame.width - safeMargin))
//
//        // spawn obstacle
//        let obstacle = SKSpriteNode(texture: obstacleTextures[0], size: obstacleSize)
//        if obstacleTextures.count > 1 {
//            let animateAction = SKAction.animate(with: obstacleTextures, timePerFrame: 0.2, resize: false, restore: true)
//            let repeatAction = SKAction.repeatForever(animateAction)
//            obstacle.run(repeatAction)
//        }
//        obstacle.position = CGPoint(x: randomX, y: frame.height + obstacleSize.height)
//
//        // set collision
//        let collisionBoxWidth = obstacleSize.width * 0.8
//        let collisionBoxHeight = obstacleSize.height
//        let collisionBoxSize = CGSize(width: collisionBoxWidth, height: collisionBoxHeight)
//
//        obstacle.physicsBody = SKPhysicsBody(rectangleOf: collisionBoxSize)
//        obstacle.physicsBody?.isDynamic = true
//        obstacle.physicsBody?.categoryBitMask = obstacleCategory
//        obstacle.physicsBody?.contactTestBitMask = snowLeopardCategory
//        obstacle.physicsBody?.collisionBitMask = 0
//
//        addChild(obstacle)
//
//        // set to move down
//        let moveAction = SKAction.moveTo(y: -obstacleSize.height, duration: 2.0)
//        let removeAction = SKAction.removeFromParent()
//        obstacle.run(SKAction.sequence([moveAction, removeAction]))
//    }
    private func spawnRock() {
        let obstacleTextures = rockTextures
        
        let obstacleWidth = frame.width * 0.18
        let obstacleHeight = obstacleWidth
        let obstacleSize = CGSize(width: obstacleWidth, height: obstacleHeight)
        
        let safeMargin: CGFloat = frame.width * 0.05
        let randomX = CGFloat.random(in: safeMargin...(frame.width - safeMargin))
        
        let obstacle = SKSpriteNode(texture: obstacleTextures[0], size: obstacleSize)
        let animateAction = SKAction.animate(with: obstacleTextures, timePerFrame: 0.2, resize: false, restore: true)
        let repeatAction = SKAction.repeatForever(animateAction)
        obstacle.run(repeatAction)
        
        obstacle.position = CGPoint(x: randomX, y: frame.height + obstacleSize.height)
        
        let collisionBoxWidth = (obstacleSize.width * 0.8) / 2
        let collisionBoxHeight = collisionBoxWidth
//        let collisionBoxSize = CGSize(width: collisionBoxWidth, height: collisionBoxHeight)
        
        obstacle.physicsBody = SKPhysicsBody(circleOfRadius: max(collisionBoxWidth, collisionBoxHeight))
        obstacle.physicsBody?.isDynamic = true
        obstacle.physicsBody?.categoryBitMask = obstacleCategory
        obstacle.physicsBody?.contactTestBitMask = snowLeopardCategory
        obstacle.physicsBody?.collisionBitMask = 0
        
        addChild(obstacle)
        
        let moveAction = SKAction.moveTo(y: -obstacleSize.height, duration: 1.5)
        let removeAction = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([moveAction, removeAction]))
    }
    private func spawnTrap() {
        let obstacleTextures = trapTextures
        
        let obstacleWidth = frame.width * 0.15
        let obstacleHeight = obstacleWidth
        let obstacleSize = CGSize(width: obstacleWidth, height: obstacleHeight)

        let safeMargin: CGFloat = frame.width * 0.08
        let randomX = CGFloat.random(in: safeMargin...(frame.width - safeMargin))
        
        let obstacle = SKSpriteNode(texture: obstacleTextures[0], size: obstacleSize)
        let animateAction = SKAction.animate(with: obstacleTextures, timePerFrame: 0.2, resize: false, restore: true)
        let repeatAction = SKAction.repeatForever(animateAction)
        obstacle.run(repeatAction)
        
        obstacle.position = CGPoint(x: randomX, y: frame.height + obstacleSize.height)
        
        let collisionBoxWidth = (obstacleSize.width * 0.8) / 2
        let collisionBoxHeight = collisionBoxWidth
//        let collisionBoxSize = CGSize(width: collisionBoxWidth, height: collisionBoxHeight)
        
        obstacle.physicsBody = SKPhysicsBody(circleOfRadius: max(collisionBoxWidth, collisionBoxHeight))
        obstacle.physicsBody?.isDynamic = true
        obstacle.physicsBody?.categoryBitMask = obstacleCategory
        obstacle.physicsBody?.contactTestBitMask = snowLeopardCategory
        obstacle.physicsBody?.collisionBitMask = 0
        
        addChild(obstacle)
        
        let moveAction = SKAction.moveTo(y: -obstacleSize.height, duration: 3.0)
        let removeAction = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([moveAction, removeAction]))
    }
    private func spawnTrashPile() {
        let obstacleTextures = trashPileTextures
        
        let obstacleWidth = frame.width * 0.23
        let obstacleHeight = obstacleWidth
        let obstacleSize = CGSize(width: obstacleWidth, height: obstacleHeight)
        
        let safeMargin: CGFloat = frame.width * 0.1
        let randomX = CGFloat.random(in: safeMargin...(frame.width - safeMargin))
        
        let obstacle = SKSpriteNode(texture: obstacleTextures[0], size: obstacleSize)
        let animateAction = SKAction.animate(with: obstacleTextures, timePerFrame: 0.2, resize: false, restore: true)
        let repeatAction = SKAction.repeatForever(animateAction)
        obstacle.run(repeatAction)
        
        obstacle.position = CGPoint(x: randomX, y: frame.height + obstacleSize.height)
        
        let collisionBoxWidth = obstacleSize.width * 0.8
        let collisionBoxHeight = obstacleSize.height * 0.8
        let collisionBoxSize = CGSize(width: collisionBoxWidth, height: collisionBoxHeight)
        
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: collisionBoxSize)
        obstacle.physicsBody?.isDynamic = true
        obstacle.physicsBody?.categoryBitMask = obstacleCategory
        obstacle.physicsBody?.contactTestBitMask = snowLeopardCategory
        obstacle.physicsBody?.collisionBitMask = 0
        
        addChild(obstacle)
        
        let moveAction = SKAction.moveTo(y: -obstacleSize.height, duration: 3.35)
        let removeAction = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    // spawn food
    private func spawnFood() {
        let foodTextures = meatTextures
        
        let foodWidth = frame.width * 0.12
        let foodHeight = foodWidth
        let foodSize = CGSize(width: foodWidth, height: foodHeight)
        
        let safeMargin: CGFloat = frame.width * 0.08
        let randomX = CGFloat.random(in: safeMargin...(frame.width - safeMargin))
        
        let food = SKSpriteNode(texture: foodTextures[0], size: foodSize)
        let animateAction = SKAction.animate(with: foodTextures, timePerFrame: 0.2, resize: false, restore: true)
        let repeatAction = SKAction.repeatForever(animateAction)
        food.run(repeatAction)
        
        food.position = CGPoint(x: randomX, y: frame.height + foodSize.height)
        
        let collisionBoxWidth = (foodSize.width * 0.8) / 2
        let collisionBoxHeight = collisionBoxWidth
//        let collisionBoxSize = CGSize(width: collisionBoxWidth, height: collisionBoxHeight)
        
        food.physicsBody = SKPhysicsBody(circleOfRadius: max(collisionBoxWidth, collisionBoxHeight))
        food.physicsBody?.isDynamic = true
        food.physicsBody?.categoryBitMask = foodCategory
        food.physicsBody?.contactTestBitMask = snowLeopardCategory
        food.physicsBody?.collisionBitMask = 0
        
        addChild(food)
        
        let moveAction = SKAction.moveTo(y: -foodSize.height, duration: 3.0)
        let removeAction = SKAction.removeFromParent()
        food.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    // Game End
    private func checkGameStatus() {
        frameCount += 1
        
        if frameCount >= scoreUpdateFrames {
            frameCount = 0
            score += 1
        }
        
        // Game Over
        if hunger < 0 && score < gameClearScore {
            Task { @MainActor in
                await gameDelegate?.endGame(score: score, isGameCleared: false)
            }
            return
        }
        
        // Game Clear
        if score >= gameClearScore {
//            score = gameClearScore // limit Maximum Score
            Task { @MainActor in
                await gameDelegate?.endGame(score: gameClearScore, isGameCleared: true)
            }
        }
    }

}

// need to improve it later
// @@preconcurrency -> use to avoid the error
// error message: Main actor-isolated instance method 'didBegin' cannot be used to satisfy nonisolated protocol requirement
extension GameScene: @preconcurrency SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == snowLeopardCategory | obstacleCategory {
            // annotating because it's awkward for the obstacle to disappear
//            let obstacle = (contact.bodyA.categoryBitMask == obstacleCategory) ? contact.bodyA.node : contact.bodyB.node
//            obstacle?.removeFromParent()
            
            hunger -= 1.0
            
            if let snowLeopard = snowLeopard {
                let originalColor = snowLeopard.color
                
                let blinkAction = SKAction.sequence([
                    SKAction.group([
                        SKAction.colorize(with: .red, colorBlendFactor: 0.7, duration: 0.1),
                        SKAction.fadeAlpha(to: 0.5, duration: 0.1)
                    ]),
                    SKAction.group([
                        SKAction.colorize(with: originalColor, colorBlendFactor: 0, duration: 0.1),
                        SKAction.fadeAlpha(to: 1.0, duration: 0.1)
                    ])
                ])
                snowLeopard.run(SKAction.repeat(blinkAction, count: 3))
            }
        }
        
        if collision == snowLeopardCategory | foodCategory {
            let food = (contact.bodyA.categoryBitMask == foodCategory) ? contact.bodyA.node : contact.bodyB.node
            
            food?.removeFromParent()
//            score += 50
            hunger += 1.0
            if hunger > hungerMax { // limit maxium hunger
                hunger = hungerMax
            }
            
            if let snowLeopard = snowLeopard {
                let currentDirection = snowLeopard.xScale > 0 ? 1.0 : -1.0
                
                snowLeopard.setScale(1.2)
                
                snowLeopard.xScale = abs(snowLeopard.xScale) * currentDirection
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    snowLeopard.setScale(1.0)
                    
                    snowLeopard.xScale = currentDirection
                }
            }
        }
    }
}

// game playe delegate
// commonly used variable management in GameScene and GamePlayView
// reference: https://developer.apple.com/documentation/spritekit/customizing-the-behavior-of-a-node/
protocol GamePlayDelegate: AnyObject {
    func updateGameState(score: Int, hunger: Float)
    func endGame(score: Int, isGameCleared: Bool) async
}
