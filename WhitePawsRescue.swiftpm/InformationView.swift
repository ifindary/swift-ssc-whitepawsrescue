//
//  InformationView.swift
//  White Paws Rescue
//
//  Created by 선애 on 2/15/25.
//

import SwiftUI

struct InformationView: View {
    @Binding var currentGameState: GameState

    let slides = [
        SlideInfo(
            slideImage: "info1",
            slideText: "The snow leopard is a wild cat that lives in the mountains at altitudes of 3,000 to 5,500 meters. Its grayish-white fur with dark spots blends into the snowy landscape, making it difficult to spot. As the top predator of the Himalayas, it plays an important role in maintaining the balance of its ecosystem. However, the International Union for Conservation of Nature(IUCN) has classified it as an 'Vulnerable' species."
        ),
        SlideInfo(
            slideImage: "info2",
            slideText: "The biggest threat to snow leopards is climate change. Rising temperatures are causing the snow line to move higher, shrinking their habitat. Human activities, such as deforestation, are also reducing the space where they can live. Studies predict that 82% of their habitat in Nepal and 85% in Bhutan could disappear. Illegal poaching further worsens the situation, leading to a decline in their population."
        ),
        SlideInfo(
            slideImage: "info3",
            slideText: "If snow leopards disappear, the food chain will be disrupted, making the entire ecosystem unstable. Their habitat also provides water, food, and biodiversity that millions of people rely on. Protecting snow leopards means protecting nature, which is directly connected to our own future."
        ),
        SlideInfo(
            slideImage: "info4",
            slideText: """
            Helping snow leopards is easier than you think. Simple actions like reducing single-use plastics and using public transportation can help protect their habitat. Joining events like Earth Hour, where lights are turned off for an hour to raise awareness, also makes a difference. This year, Earth Hour will take place on Saturday, March 22, at 8:30 PM.
            Your small actions can have a big impact. Let’s work together to protect snow leopards and nature!
            """
        )
    ]

    var body: some View {
        ZStack {
            Image("snowmountain")
                .resizable()
                .scaledToFill()
                .blur(radius: 3)
                .brightness(-0.1)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                TabView {
                    ForEach(0..<slides.count, id: \.self) { index in
                        OneSlideView(slideInfo: slides[index])
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .frame(height: 850)
                .padding(.bottom, 10)
                
                Button {
                    currentGameState = .home
                } label: {
                    Text("I got it!")
                        .font(.system(size: 30, weight: .bold))
                        .frame(width: 200, height: 100)
                        .background(Color("paleblue"))
                        .foregroundColor(.white)
                        .cornerRadius(50)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .padding(.bottom, 20)
            }
        }
    }
}

struct OneSlideView: View {
    let slideInfo: SlideInfo
    let textSize : CGFloat = 24
    
    var body: some View {
        VStack {
            Image("informationbox")
                .resizable()
                .scaledToFit()
                .overlay {
                    VStack {
                        Spacer()
                            .frame(height: 200)
                        
                        Image(slideInfo.slideImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .padding(.horizontal, 50)
                        
                        Text(makeAttributedStr(from: slideInfo.slideText))
                            .font(.system(size: textSize))
//                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 50)
//                            .padding(.vertical, 10)
                            .frame(height: 350)
                        
                        Spacer()
                    }
                }
        }
    }
    
    func makeAttributedStr(from text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        let warningWords = ["Vulnerable", "climate change"]
        let boldWords = ["snow leopard", "snow leopards", "Earth Hour"]
        
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

struct SlideInfo {
    let slideImage: String
//    let slidetitle: String
    let slideText: String
}
