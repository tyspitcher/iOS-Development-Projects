//
//  Calculator.swift
//  Calculator Project
//
//  Created by Jane Madsen on 9/29/25.
//

import SwiftUI

@Observable
class Calculator {
    var displayedString = "0"  // Any time you update this String, it will display on the calculator.
    
    // Add additional variables here.
    
    // mentally keeping runningTotal in a basket on the 'left' side and
    // new inputs on 'right'
    var runningTotal: Double?
    var lastEnteredOperator: CalculatorInput?
    // mentally switching on and off when typing numbers so
    // app knows when to start new number (when false) or continue with
    // current number string (when true)
    var isTypingNumber: Bool = false
    
    func handleInput(_ input: CalculatorInput) {
        
        // Each case below represents a single button pressed on the calculator. Add a function for each; the default case covers the number buttons and has been set up for you, but feel free to change this as you see fit.
        switch input {
        case .backspace: backspace()
        case .clear: clear()
        case .percent: break
        case .divide: inputOperator(input)
        case .multiply: inputOperator(input)
        case .subtract: inputOperator(input)
        case .add: inputOperator(input)
        case .invertSign: invertSign()
        case .decimal: decimal()
        case .equal: equal()
        default:
            number(Int(input.rawValue)!)
        }
    }
    
    // I noticed I had to reset the state a lot
    // in case of the Error I put in for dividing
    // by zero, so I just made this function to
    // easily reset the state where needed
    func reset() {
        displayedString = "0"
        runningTotal = nil
        lastEnteredOperator = nil
        isTypingNumber = false
    }
    
    // no math happens in func number(_:), it just
    // updates displayedString if it's at 0 or
    // appends if there's already something else
    // there
    func number(_ number: Int) {
        let n = String(number)
        if displayedString == "Error" {
            reset()
        }
        
        // If not currently typing, start a new number entry
        // rather than adding to an existing one
        guard isTypingNumber else {
            displayedString = n
            isTypingNumber = true
            return
        }

        // if already typing then append to the end of
        // the existing number String or replace leading zero
        if displayedString == "0" {
            displayedString = n
        } else {
            displayedString.append(n)
        }
    }
    
    // if there's more than one number (i.e. count is
    // greater than 1) then it will remove last,
    // otherwise it will set displayedString to 0
    func backspace() {
        if displayedString == "Error" {
            reset()
            return
        }
        
        // I noticed that I was able to backspace on a
        // result, so I added this guard so backspace
        // only works while typing, not on results
        guard isTypingNumber else {
            return
        }
            

        if displayedString.count > 1 {
            displayedString.removeLast()
            if displayedString == "-" {
                // minus without number there isn't a valid entry
                // so I just set it back to 0
                displayedString = "0"
                isTypingNumber = false
            }
        } else {
            displayedString = "0"
            isTypingNumber = false
        }
    }
    
    // func clear will just set display back to
    // 0 and it won't touch the runningTotal or
    // lastEnteredOperator so those will keep their values
    func clear() {
        if displayedString == "Error" {
            reset()
            return
        }
        displayedString = "0"
        isTypingNumber = false
    }
    
    // just adds a decimal after a number or adds the '0.'
    // if there hasn't been another number typed yet
    func decimal() {
        if displayedString == "Error" {
            reset()
            return
        }

        if isTypingNumber {
            if !displayedString.contains(".") {
                displayedString.append(".")
            }
            // else do nothing prevents multiple decimals
        } else {
            displayedString = "0." // <- if decimal starts the String
                                    //   just adds a 0 prefix
            isTypingNumber = true  // <- so you can add to it
        }
    }
    
   
    
    // takes what's in the right and goes ahead and moves it
    // into the left according to what the operator said to do
    // it then applies the operator to whatever the next input
    // is or changes the operator if a new one is chosen
    func inputOperator(_ op: CalculatorInput) {
        
        if displayedString == "Error" {
            reset()
            return
        }

        // checks to see if right is the same as displayedString
        // and if isTyping is true or runningTotal is nil
        // and if so it will applyPendingOperation with the
        // right side
        if let right = Double(displayedString) {
            // if we were already typing OR we’re starting fresh,
            // applyPendingOperation with right.
            if isTypingNumber || runningTotal == nil {
                applyOperation(with: right)
            }
        } else {
            return
        }
        // changes lastEnteredOperator to op and changes
        // is typing to false after other operations
        // have completed so it's ready for a new String
        lastEnteredOperator = op //<- added this state so I can guard this
                                 // in func applyOperation() next
        isTypingNumber = false
    }
    
    // put everything into the left side and stop any other
    // actions for now as opposed to inputOperator which will
    // add the next operator
    func equal() {
        if displayedString == "Error" {
            reset()
            return
        }

        guard let right = Double(displayedString) else {
            return
        }
        
        applyOperation(with: right)

        isTypingNumber = false
        // clearing the operator so when you keep
        // pushing equals it doesn't repeat the last op
        lastEnteredOperator = nil
    }
    
    // func applyPendingOperation starts running total with the
    // current value (right side) or uses the current input to
    // initialize the running total if no operator is set yet
    func applyOperation(with right: Double) {
        // checking to see if there's already a pending operator
        // and if not it initializes the runningTotal
        guard let op = lastEnteredOperator else {
            runningTotal = right
            displayedString = String(right)
            return
        }

        // if left is missing, also start the chain safely
        guard let left = runningTotal else {
            runningTotal = right
            displayedString = String(right)
            return
        }

        var result = left  // <- place to hold outcome so I can assign it
                           //    back to runningTotal and displayedString
        if op == .add {
            result = left + right
        } else if op == .subtract {
            result = left - right
        } else if op == .multiply {
            result = left * right
        } else if op == .divide {
            if right == 0 {  // <- can't divide by 0, create Error
                displayedString = "Error"
                runningTotal = nil
                lastEnteredOperator = nil
                isTypingNumber = false
                return
            } else {
                result = left / right
            }
        }

        runningTotal = result
        displayedString = String(result)
    }
    
    
    func invertSign() {
        if displayedString == "Error" {
            reset()
            return
        }
        // do nothing if "0" is in the display because -0
        // doesn't really make sense
        if displayedString == "0" || displayedString == "0." {
            return
        }
        // being able to switch '-' on and off with each press
        if displayedString.hasPrefix("-") {
            displayedString.removeFirst()
        } else {
            displayedString = "-" + displayedString
        }
        
        isTypingNumber = true
    }
}
    
    #Preview {
        ContentView()
    }
