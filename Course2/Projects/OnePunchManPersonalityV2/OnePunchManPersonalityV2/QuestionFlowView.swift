//
//  QuestionFlowView.swift
//  OnePunchManPersonalityV2
//
//  Created by Tyson Pitcher on 3/13/26.
//

import Foundation
import SwiftUI

struct QuestionFlowView: View {
    let question: Question
    @Environment(QuizManager.self) private var quizManager
    
    var body: some View {
        VStack {
            Image("fist")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
            Text(question.text)
                .font(.custom("Impact", size: 30))
                .multilineTextAlignment(.center)
                .padding()
            
            switch question.type {
            case .multiple:
                MultipleResponseView(question: question)
            case .single:
                SingleResponseView(viewModel: SingleResponseViewModel(question: question))
            case .ranged:
                RangedResponseView(question: question)
            }
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .black, location: 0.0),
                    .init(color: .red, location: 0.15),
                    .init(color: .red, location: 0.85),
                    .init(color: .black, location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                if let previous = previousQuestion() {
                    NavigationLink("Back") { QuestionFlowView(question: previous) }
                }
                Spacer()
                if let next = nextQuestion() {
                    NavigationLink("Next") { QuestionFlowView(question: next) }
                } else {
                    NavigationLink("Finish") { ResultsView() }
                }
            }
        }
    }
    
    
    // Navigation functions
    private func currentIndex() -> Int? {
        quizManager.questionList.firstIndex { $0.text == question.text }
    }
    private func nextQuestion() -> Question? {
        guard let index = currentIndex() else { return nil }
        let next = index + 1
        return next < quizManager.questionList.count ? quizManager.questionList[next] : nil
    }
    private func previousQuestion() -> Question? {
        guard let index = currentIndex(), index > 0 else { return nil }
        let previous = index - 1
        return quizManager.questionList[previous]
    }
}
