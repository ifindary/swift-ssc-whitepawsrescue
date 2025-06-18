//
//  IntroView.swift
//  White Paws Rescue
//
//  Created by 선애 on 2/15/25.
//

import SwiftUI

struct IntroView: View {
    @Binding var currentGameState: GameState
    
    @State private var currentDialogIndex = 0
    
    let textSize : CGFloat = 30
    
    let dialogs = [
        Dialog(mainImage: "intro1", faceImage: "snowleopardsmile", dialogText: """
            Hello! I'm a snow leopard.
            I live in this mountain.
            """),
        Dialog(mainImage: "intro2", faceImage: "snowleopardsad", dialogText: "But the snow is melting, I'm getting hungrier... Help me climb up the mountain! My goal is to reach 1000m!"),
        Dialog(mainImage: "intro3", faceImage: "snowleopardnormal", dialogText: "You can change my running direction by tapping the screen. Don’t let my hunger reach 0."),
        Dialog(mainImage: "intro4", faceImage: "snowleopardsad", dialogText: "The path is rough... There are traps left by hunters, rolling rocks, and piles of trash everywhere. I can’t hit any obstacles or walls!"),
        Dialog(mainImage: "intro5", faceImage: "snowleopardnormal", dialogText: "If I find food, don’t let me miss it. Please help me!")
    ]
    
    var body: some View {
        ZStack {
            Image("meltingmountain")
                .resizable()
                .scaledToFill()
                .blur(radius: 3)
                .brightness(0.1)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
//                Spacer()
                
                Image(dialogs[currentDialogIndex].mainImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 500, height: 400)
                    .padding(.top, 50)
//                    .padding(.bottom, 50)
                
//                Spacer()
                
                HStack(alignment: .top, spacing: 15) {
                    Image(dialogs[currentDialogIndex].faceImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .padding(.leading, 40)
                        .padding(.top, 60)
                    
                    ZStack {
                        Image("introdialogbox")
                            .resizable()
                            .scaledToFit()
                        
                        Text(makeAttributedStr(from: dialogs[currentDialogIndex].dialogText))
                            .font(.system(size: textSize))
                            .foregroundColor(.black)
                            .frame(maxWidth: 400)
                            .padding(.leading, 20)
                        
                    }
                    .padding(.trailing, 40)
                }
                .padding(.horizontal, 20)
                
//                .onTapGesture {
//                    if currentDialogIndex < dialogs.count - 1 {
//                        currentDialogIndex += 1
//                    } else {
//                        currentGameState = .gameplay
//                    }
//                }
                
                if currentDialogIndex == dialogs.count - 1 {
                    Button(action: {
                        currentGameState = .gameplay
                    }) {
                        Text("""
                        I'm with you.
                        Let’s go!
                        """)
                            .font(.system(size: 30, weight: .bold))
                            .padding()
                            .frame(width: 250, height: 150)
                            .background(Color("eyeblue"))
                            .foregroundColor(.white)
                            .cornerRadius(50)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                } else {
                    Button(action: {
                        currentDialogIndex += 1
                    }) {
                        Text("Next")
                            .font(.system(size: 30, weight: .bold))
                            .padding()
                            .frame(width: 150, height: 100)
                            .background(Color("paleblue"))
                            .foregroundColor(.white)
                            .cornerRadius(50)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 80)
                }
            }
        }
    }
    
    
    func makeAttributedStr(from text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        let warningWords = ["0", "hungrier", "traps", "rolling rocks", "piles of trash"]
        let boldWords = ["snow leopard", "1000m", "food", "tapping"]
        
        for word1 in warningWords {
            if let range = attributedString.range(of: word1) {
                attributedString[range].font = .system(size: textSize, weight: .bold)
                attributedString[range].foregroundColor = Color("warningyellow")
            }
        }
        
        for word2 in boldWords {
            if let range = attributedString.range(of: word2) {
                attributedString[range].font = .system(size: textSize, weight: .bold)
                attributedString[range].foregroundColor = Color("eyeblue")
            }
        }
        
        return attributedString
    }
}

struct Dialog {
    var mainImage: String
    var faceImage: String
    var dialogText: String
}
