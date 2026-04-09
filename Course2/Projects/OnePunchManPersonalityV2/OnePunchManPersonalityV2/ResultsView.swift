//
//  ResultsView.swift
//  OnePunchManPersonalityV2
//
//  Created by Tyson Pitcher on 3/13/26.
//
import Foundation
import SwiftUI


struct ResultsView: View {
    @Environment(QuizManager.self) private var quizManager
    @State private var result: CharacterResult =
        characterResults.first { $0.character == .saitama }!
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack {
                    Text(result.resultStatement)
                        .font(Font.custom("Impact", size: 34))
                        .foregroundStyle(Color.white)
                        .padding(7)
                    
                    Text(result.title)
                        .font(.title2)
                        .foregroundStyle(Color.white)
                    
                    result.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(7)
                    
                    Text(result.blurb)
                        .foregroundStyle(Color.white)
                        .padding()
                        .padding(.horizontal, 25)
                    
                    NavigationLink(destination: TitleView()
                                    .onAppear { quizManager.selectAnswers = [:] }) {
                        Text("Take Quiz Again")
                            .font(.title)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundStyle(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .padding(.top, 16)
                }
            }
        }
        .onAppear {
            let winner = quizManager.calculateResults().winner
            result = characterResults.first { $0.character == winner }
                ?? characterResults.first { $0.character == .saitama }!
        
        }
    }
}
