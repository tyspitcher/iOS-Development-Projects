//
//
//  SubviewSingleResponseView.swift
//  OnePunchManPersonalityV2
//
//  Created by Tyson Pitcher on 3/13/26.
//

import Foundation
import SwiftUI

struct RangedResponseView: View {
    @Environment(QuizManager.self.self) private var quizManager
    let question: Question
    @State private var selectedAnswer: Float = 0
    var body: some View {
        VStack {
            VStack(spacing: 16) {
                Slider(value: $selectedAnswer, in: 0...3, step: 1)
                    .tint(.yellow)
                    .padding(.horizontal)
                
                Text(question.answers[Int(selectedAnswer)].text)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                HStack(alignment: .top) {
                    ForEach(question.answers.indices, id: \.self) { i in
                        Text(question.answers[i].text)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            
            .onChange(of: selectedAnswer) { oldValue, newValue in
                guard let qIndex = quizManager.questionList.firstIndex(where: { $0.text == question.text }) else { return }
                let idx = Int(newValue)
                quizManager.selectAnswers(forQuestionAt: qIndex, selections: [idx])
            }
        }
        .padding()
    }
}
#Preview("RangedResponseView – From QuizManager[2]") {
    let manager = QuizManager()
    let sampleQuestion = manager.questionList[2]
    return RangedResponseView(question: sampleQuestion)
        .environment(manager)
        .padding()
}
