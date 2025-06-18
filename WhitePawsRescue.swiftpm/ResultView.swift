//
//  ResultView.swift
//  White Paws Rescue
//
//  Created by 선애 on 2/15/25.
//

import SwiftUI
import SpriteKit

struct ResultView: View {
    @Binding var currentGameState: GameState
    @Binding var score: Int
    @Binding var isGameCleared: Bool
    
    var scene: SKScene {
        let scene = WanderScene()
        
        let screenBounds = UIScreen.main.bounds
            scene.size = CGSize(width: screenBounds.width, height: screenBounds.height)
        
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    let gameTips = [
        "Be careful. The rocks move faster.",
        "Avoid hitting the walls.",
        "Eat food to run farther."
    ]
    
    @State private var currentTip = ""
    
    var body: some View {
        ZStack {
            
            if isGameCleared {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
            } else {
                Image("meltingmountain")
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 3)
                    .brightness(-0.1)
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(isGameCleared ? "gameclear" : "gameover")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 700, height: 350)
                    .padding(.bottom, 20)
                
//                Text(isGameCleared ? "You did it!" : "Try again...")
//                    .font(.largeTitle)
                
                if !isGameCleared {
                    Text("You Reached \(score)m")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "pawprint.fill")
                        
                        Text("Tip : \(currentTip)")
                            .multilineTextAlignment(.leading)
                    }
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                }
                
                Button(action: {
                    currentGameState = .home
                    score = 0
                    isGameCleared = false
                }) {
                    Text("Home")
                        .font(.system(size: 30, weight: .bold))
                        .padding()
                        .frame(width: 200, height: 100)
                        .background(Color("paleblue"))
                        .foregroundColor(.white)
                        .cornerRadius(50)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                
                Button(action: {
                    if isGameCleared {
                        currentGameState = .information
                    } else {
                        currentGameState = .gameplay
                        score = 0
                        isGameCleared = false
                    }
                }) {
                    Text(isGameCleared ? "Did you know?" : "Restart")
                        .font(.system(size: 30, weight: .bold))
                        .frame(width: isGameCleared ? 300 : 200, height: 100)
                        .background(isGameCleared ? Color("eyeblue") : Color("paleblue"))
                        .foregroundColor(.white)
                        .cornerRadius(50)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                
                Spacer()
            }
        }
        .onAppear {
            if !isGameCleared {
                currentTip = gameTips.randomElement() ?? gameTips[0]
            }
        }
    }
}
