//
//  CalculatorInput.swift
//  Calculator Project
//
//  Created by Jane Madsen on 9/29/25.
//

import SwiftUI

enum CalculatorInput: String, CaseIterable {
    case backspace
    case clear
    case percent
    case divide
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case multiply
    case four = "4"
    case five = "5"
    case six = "6"
    case subtract
    case one = "1"
    case two = "2"
    case three = "3"
    case add
    case invertSign
    case zero = "0"
    case decimal = "."
    case equal
}
extension CalculatorInput {
    var isDigitOrDecimal: Bool {
        switch self {
        case .decimal:
            return true
        case .backspace, .clear, .percent, .divide, .multiply, .subtract, .add, .invertSign, .equal:
            return false
        default:
            // Covers numeric cases like "0"..."9"
            return Int(self.rawValue) != nil
        }
    }
}
