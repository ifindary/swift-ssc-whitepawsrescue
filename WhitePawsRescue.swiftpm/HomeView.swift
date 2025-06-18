//
//  HomeView.swift
//  White Paws Rescue
//
//  Created by 선애 on 2/15/25.
//

import SwiftUI
import SpriteKit

struct HomeView: View {
    @Binding var currentGameState: GameState
    
    var scene: SKScene {
        let scene = WanderScene()
        let screenBounds = UIScreen.main.bounds
            scene.size = CGSize(width: screenBounds.width, height: screenBounds.height)
        
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    var body: some View {
        ZStack {
//            Image("mountain")
//                .resizable()
//                .scaledToFill()
//                .blur(radius: 3)
//                .brightness(0.05)
//                .edgesIgnoringSafeArea(.all)
            
            SpriteView(scene: scene)
                .ignoresSafeArea()
            
            VStack {
                Image("logo")
                    .resizable()
                    .brightness(0.05)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 500, height: 500)
                
//                Text("Help the snow leopard!")
//                    .font(.headline)
//                    .foregroundColor(.gray)
                
                Button(action: {
                    currentGameState = .intro
                }) {
                    Text("Start")
                        .font(.system(size: 30, weight: .bold))
                        .padding()
                        .frame(width: 200, height: 100)
                        .background(Color("eyeblue"))
                        .foregroundColor(.white)
                        .cornerRadius(50)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                }
            }
        }
    }
}
