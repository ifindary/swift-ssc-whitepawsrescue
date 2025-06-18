//
//  GamePlayView.swift
//  White Paws Rescue
//
//  Created by 선애 on 2/15/25.
//

import SwiftUI
import SpriteKit

struct GamePlayView: View {
    @Binding var currentGameState: GameState
    @Binding var score: Int
    @Binding var isGameCleared: Bool
    
    @State private var hunger: Float = 0
    
    let hungerIconSize: CGFloat = 80
    
    var gameScene: SKScene {
        let gameScene = GameScene()
        let screenBounds = UIScreen.main.bounds
        gameScene.size = CGSize(width: screenBounds.width, height: screenBounds.height)
        
        gameScene.scaleMode = .aspectFill
        gameScene.gameDelegate = GamePlayCoordinator(currentGameState: $currentGameState, score: $score, isGameCleared: $isGameCleared, hunger: $hunger)
        
        return gameScene
    }
    
    var body: some View {
        ZStack {
            SpriteView(scene: gameScene)
                .ignoresSafeArea()
            
            VStack {
                HStack {
//                    VStack {
//                        Text("hunger")
//                            .font(.system(size: 20, weight: .bold))
//                            .foregroundColor(.black)
//
//                        ZStack(alignment: .leading) {
//                            Rectangle()
//                                .frame(width: 200, height: 30)
//                                .foregroundColor(.gray)
//                                .cornerRadius(5)
//
//                            Rectangle()
//                                .frame(width: CGFloat(hunger / 3.0) * 200, height: 20)
//                                .foregroundColor(hungerColor)
//                                .cornerRadius(5)
//                                .foregroundColor(hunger > 2.0 ? .green : hunger > 1.0 ? .yellow : .red)
//                        }
//                    }

                    HungerView(hunger: hunger, iconSize: hungerIconSize)
                    
                    Spacer()
                    
                    ScoreView(score: score)
                }
                .padding(.horizontal, 30)
                .padding(.top, 5)
                    
                Spacer()
                    
//                    Text("\(score)m")
//                        .font(.system(size: 40, weight: .bold))
//                        .foregroundColor(.black)
//                        .padding(.trailing, 50)
                }
//                .padding(.top, 10)
                
//                Spacer()
            }
        }

//    var hungerColor: Color {
//        if hunger > 1.0 {
//            return .green
//        } else if hunger > 2.0 {
//            return .yellow
//        } else {
//            return .red
//        }
//    }
}

struct HungerView: View {
    let hunger: Float
    let iconSize: CGFloat
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3) { index in
                HungerIcon(isEmpty: isIconEmpty(index: index), fillAmount: getFillAmount(index: index), size: iconSize)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .gray.opacity(0.2), radius: 5)
        )
    }
    
    func isIconEmpty(index: Int) -> Bool {
        return hunger <= Float(index)
    }
    
    func getFillAmount(index: Int) -> Float {
        let currentAmount = hunger - Float(index)
        if currentAmount >= 1 {
            return 1
        } else if currentAmount <= 0 {
            return 0
        } else {
            return currentAmount
        }
    }
}

struct HungerIcon: View {
    let isEmpty: Bool
    let fillAmount: Float
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Image("hungerEmpty")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
//                .opacity(0.5)
            
            Image("hungerFull")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .mask(
                    Rectangle()
                        .frame(height: size * CGFloat(fillAmount))
                        .offset(y: size * (1 - CGFloat(fillAmount)))
                )
        }
    }
}

struct ScoreView: View {
    let score: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "pawprint.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
            
            Text("\(score)m")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.black)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .gray.opacity(0.2), radius: 5)
        )
    }
}

class GamePlayCoordinator: GamePlayDelegate {
    @Binding private var currentGameState: GameState
    @Binding private var score: Int
    @Binding private var isGameCleared: Bool
    @Binding private var hunger: Float
    
    init(currentGameState: Binding<GameState>, score: Binding<Int>, isGameCleared: Binding<Bool>, hunger: Binding<Float>) {
        _currentGameState = currentGameState
        _score = score
        _isGameCleared = isGameCleared
        _hunger = hunger
    }
    
    func updateGameState(score: Int, hunger: Float) {
        self.score = score
        self.hunger = hunger
    }
    
    func endGame(score: Int, isGameCleared: Bool) async {
        self.currentGameState = .result
        self.score = score
        self.isGameCleared = isGameCleared
    }
}
