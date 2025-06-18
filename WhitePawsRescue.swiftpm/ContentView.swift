//
//  ContentView.swift
//  White Paws Rescue
//
//  Created by 선애 on 2/14/25.
//
// deciding which view is displayed
// init view : deviceRotate
// basic route : deviceRotate -> home -> intro -> gameplay -> result -> informtaion -> home

import SwiftUI

struct ContentView: View {
    @State private var currentGameState: GameState = .deviceRotate
    @State private var score: Int = 0
    @State private var isGameCleared: Bool = false
    
    var body: some View {
        ZStack {
            switch currentGameState {
            case .deviceRotate: // notice to use the portrait mode
                deviceRotateView(currentGameState: $currentGameState)
            case .home:
                HomeView(currentGameState: $currentGameState)
            case .intro: // how to play
                IntroView(currentGameState: $currentGameState)
            case .gameplay:
                GamePlayView(currentGameState: $currentGameState, score: $score, isGameCleared: $isGameCleared)
            case .result: // game result
                ResultView(currentGameState: $currentGameState, score: $score, isGameCleared: $isGameCleared)
            case .information: // show the reason we have to protect the snow leopard and nature
                InformationView(currentGameState: $currentGameState)
            }
        }
    }
}
