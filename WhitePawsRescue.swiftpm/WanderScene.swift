//
//  WanderScene.swift
//  White Paws Rescue
//
//  Created by 선애 on 2/22/25.
//
// dummy snow leopard

import SpriteKit

class WanderScene: SKScene {
    private var snowLeopard: SKSpriteNode?
    private var snowLeopardTextures: [SKTexture] = []
    private var mountainTexture: SKTexture?
    
    private var isMovingRight = true
    private var isMovingUp = true
    
    private var mountainBackground: SKSpriteNode?
    
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        
        loadTextures()
        setupMountain()
        spawnSnowLeopard()
    }
    
    private func loadTextures() {
        let textures = Textures()
        snowLeopardTextures = textures.snowLeopard
        mountainTexture = textures.snowMountain
    }
    
    private func setupMountain() {
        let backgroundWidth = frame.width
        let backgroundHeight = frame.height * 1.5
        
        mountainBackground = SKSpriteNode(texture: mountainTexture, size: CGSize(width: backgroundWidth, height: backgroundHeight))
        
        
        if let mountainBackground = mountainBackground {
            mountainBackground.position = CGPoint(x: frame.midX, y: frame.midY)
            mountainBackground.zPosition = -10 // lowest

            addChild(mountainBackground)
        }
    }
    
    private func spawnSnowLeopard() {
        physicsWorld.gravity = .zero
        
        let snowLeopardSize = CGSize(width: frame.width * 0.22, height: frame.width * 0.22)
        
        snowLeopard = SKSpriteNode(texture: snowLeopardTextures[0], size: snowLeopardSize)
        
        let animateAction = SKAction.animate(with: snowLeopardTextures,
                                            timePerFrame: 0.2,
                                            resize: false,
                                            restore: true)
        let repeatAction = SKAction.repeatForever(animateAction)
        
        snowLeopard?.run(repeatAction)
        
        if let snowLeopard = snowLeopard {
            snowLeopard.position = CGPoint(x: frame.midX, y: frame.midY * 0.5)
            addChild(snowLeopard)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        moveSnowLeopard()
    }
    
    private func moveSnowLeopard() {
        let moveAmountX: CGFloat = 5.0
        let moveAmountY: CGFloat = 5.0

        let movementX = isMovingRight ? moveAmountX : -moveAmountX
        let movementY = isMovingUp ? moveAmountY : -moveAmountY
        
        if let snowLeopard = snowLeopard {
            snowLeopard.position.x += movementX
            snowLeopard.position.y += movementY
            
            snowLeopard.xScale = isMovingRight ? abs(snowLeopard.xScale) : -abs(snowLeopard.xScale)
            snowLeopard.yScale = isMovingUp ? abs(snowLeopard.yScale) : -abs(snowLeopard.yScale)
            
            if snowLeopard.position.x <= snowLeopard.size.width / 2 || snowLeopard.position.x >= frame.width - snowLeopard.size.width / 2 {
                isMovingRight.toggle()
            }
            if snowLeopard.position.y <= snowLeopard.size.height / 2 || snowLeopard.position.y >= frame.height - snowLeopard.size.height / 2 {
                isMovingUp.toggle()
            }
        }
    }
}
