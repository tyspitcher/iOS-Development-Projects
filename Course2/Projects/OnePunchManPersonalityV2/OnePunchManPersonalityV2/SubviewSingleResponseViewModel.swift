//
//
//  SubviewSingleResponseView.swift
//  OnePunchManPersonalityV2
//
//  Created by Tyson Pitcher on 3/13/26.
//

import Foundation
import SwiftUI
import Observation

@Observable
class SingleResponseViewModel {
    let question: Question
    var selectedIndex: Int
    
    init(question: Question, selectedIndex: Int = 0) {
        self.question = question
        self.selectedIndex = selectedIndex
    }
    
    func selectAnswer(index: Int) {
        selectedIndex = index
    }
}
