//
//  deviceRotateView.swift
//  White Paws Rescue
//
//  Created by 선애 on 2/23/25.
//

import SwiftUI
import SpriteKit

struct deviceRotateView: View {
    @Binding var currentGameState: GameState
    
    let textSize: CGFloat = 30
    let deviceRotateText = "For the best experience, please use this app in portrait mode. Rotate your iPad to continue."
    
    let scene: SKScene = {
        let scene = deviceRotateScene()
        scene.size = CGSize(width: 500, height: 500)
        scene.scaleMode = .fill
        return scene
    }()
    
    var body: some View {
        ZStack {
            Image("snowmountain")
                .resizable()
                .scaledToFill()
                .brightness(-0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                SpriteView(scene: scene, options: [.allowsTransparency])
                    .frame(width: 600, height: 600)
                    .ignoresSafeArea()
                
                Text(makeAttributedStr(from: deviceRotateText))
                    .font(.system(size: textSize))
                    .frame(maxWidth: 600)
                    .foregroundColor(.white)
                    .padding(.vertical, 20)
                
                Button(action: {
                    currentGameState = .home
                }) {
                    Text("I'm ready!")
                        .font(.system(size: textSize, weight: .bold))
                        .frame(width: 200, height: 100)
                        .background(Color("paleblue"))
                        .foregroundColor(.white)
                        .cornerRadius(50)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                }
            }
        }
    }
    
    func makeAttributedStr(from text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        let boldWords = ["portrait mode"]
        
        for word in boldWords {
            if let range = attributedString.range(of: word) {
                attributedString[range].font = .system(size: textSize, weight: .bold)
                attributedString[range].foregroundColor = Color("paleblue")
            }
        }
        
        return attributedString
    }
}

class deviceRotateScene: SKScene {
    private var deviceRotateTextures: [SKTexture] = []
    
    override func sceneDidLoad() {
        backgroundColor = .clear
    }
    
    override func didMove(to view: SKView) {
        loadTextures()
        spawnDevice()
    }
    
    private func loadTextures() {
        let textures = Textures()
        deviceRotateTextures = textures.deviceRotate
    }
    
    private func spawnDevice() {
        let rotateSprite = SKSpriteNode(texture: deviceRotateTextures[0])
        rotateSprite.position = CGPoint(x: frame.midX, y: frame.midY)
        rotateSprite.setScale(0.9)
        addChild(rotateSprite)
        
        let animation = SKAction.animate(with: deviceRotateTextures, timePerFrame: 0.7, resize: false, restore: true)
        let repeatForever = SKAction.repeatForever(animation)
        rotateSprite.run(repeatForever)
    }
}
