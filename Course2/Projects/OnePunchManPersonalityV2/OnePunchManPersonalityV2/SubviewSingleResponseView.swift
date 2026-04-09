//
//
//  SubviewSingleResponseView.swift
//  OnePunchManPersonalityV2
//
//  Created by Tyson Pitcher on 3/13/26.
//

import Foundation
import SwiftUI

struct SingleResponseView: View {
    @Environment(QuizManager.self) private var quizManager
    @State private var viewModel: SingleResponseViewModel
    
    init(viewModel: SingleResponseViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    private var bindingForSelection: Binding<Int> {
        Binding(
            get: { viewModel.selectedIndex },
            set: { newValue in viewModel.selectAnswer(index: newValue) }
        )
    }
    var body: some View {
        VStack {
            
            Picker("", selection: bindingForSelection) {
                ForEach(viewModel.question.answers.indices, id: \.self) { index in
                    Text(viewModel.question.answers[index].text)
                        .tag(index)
                }
            }
            .tint(.primary)
        }
        
        .onChange(of: viewModel.selectedIndex) { oldIndex, newIndex in
            guard let questionIndex = quizManager.questionList.firstIndex(where: { $0.text == viewModel.question.text }) else { return }
            quizManager.selectAnswers(forQuestionAt: questionIndex, selections: [newIndex])
        }
        .padding()
    }
    
}
