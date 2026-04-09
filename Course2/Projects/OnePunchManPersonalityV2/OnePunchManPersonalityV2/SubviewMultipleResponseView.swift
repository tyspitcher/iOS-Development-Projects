//
//
//  SubviewSingleResponseView.swift
//  OnePunchManPersonalityV2
//
//  Created by Tyson Pitcher on 3/13/26.
//

import Foundation
import SwiftUI

struct MultipleResponseView: View {
    @Environment(QuizManager.self.self) private var quizManager
    @State private var isSelected0: Bool = false
    @State private var isSelected1: Bool = false
    @State private var isSelected2: Bool = false
    @State private var isSelected3: Bool = false
    let question: Question
    
    private var selectedIndices: [Int] {
        var indices : [Int] = []
        if isSelected0 { indices.append (0) }
        if isSelected0 { indices.append (1) }
        if isSelected0 { indices.append (2) }
        if isSelected0 { indices.append (3) }
        return indices
    }
    var body: some View {
        VStack {
            Toggle(question.answers[0].text, isOn: $isSelected0)
                .tint(.yellow)
            Toggle(question.answers[1].text, isOn: $isSelected1)
                .tint(.yellow)
            Toggle(question.answers[2].text, isOn: $isSelected2)
                .tint(.yellow)
            Toggle(question.answers[3].text, isOn: $isSelected3)
                .tint(.yellow)
        }
        .onChange(of: [isSelected0, isSelected1, isSelected2, isSelected3]) { oldValue, newValue in
            guard let questionIndex = quizManager.questionList.firstIndex(where: { $0.text == question.text }) else { return }
            quizManager.selectAnswers(forQuestionAt: questionIndex, selections: selectedIndices)
        }
        .padding()
    }
}
#Preview("MultipleResponseView – From QuizManager[2]") {
    let manager = QuizManager()
    let sampleQuestion = manager.questionList[2]
    return MultipleResponseView(question: sampleQuestion)
        .environment(manager)
        .padding()
}
