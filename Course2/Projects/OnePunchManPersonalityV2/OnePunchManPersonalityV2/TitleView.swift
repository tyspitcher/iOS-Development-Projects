//
//  ContentView.swift
//  OnePunchManPersonalityV2
//
//  Created by Tyson Pitcher on 3/13/26.
//

import Foundation
import SwiftUI

struct TitleView: View {
    @State private var quizManager = QuizManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                Image("titleScreen")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 470, height: 470)
                    .padding(.bottom, 80)
                
                VStack {
                    Spacer()
                    NavigationLink(destination:QuestionFlowView(question: quizManager.questionList[0])) {
                        Text("BEGIN QUIZ")
                            .font(.title)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(30)
                            .background(Color.black)
                            .foregroundStyle(Color.white)
                    }
                }
            }
        }
        .environment(quizManager)
    }
}

#Preview {
    TitleView()
}
