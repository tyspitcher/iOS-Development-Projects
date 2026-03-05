//
//  ContentView.swift
//  Calculator Project
//
//  Created by Jane Madsen on 9/29/25.
//

import SwiftUI
import UIKit
struct ContentView: View {
    @State var calculator = Calculator()
    
    let columns = Array<GridItem>.init(repeating: GridItem(.flexible(minimum: 50, maximum: 200)), count: 4)
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(calculator.displayedString)
                .font(.custom("Papyrus", size: 90))
                .minimumScaleFactor(0.3)
                .foregroundStyle(.black)
                .frame(height: 150)
                .containerRelativeFrame(.horizontal)
                .background {
                    ConcentricRectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .blue,
                                    .white
                                ],
                                startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                }
            
            LazyVGrid(columns: columns) {
                ForEach(CalculatorInput.allCases, id: \.self) { input in
                    
                    Button {
                        calculator.handleInput(input)
                    } label: {
                        VStack {
                            Spacer()
                            
                            HStack {
                                Spacer()
                                
                                input.label
                                    .font(.custom("ComicSansMS", size: 30))
                                
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    .buttonStyle(.glassProminent)
                    .tint(input.color)
                }
            }
            
            Spacer()
        }
       
        .background {
            Color.blue
                .ignoresSafeArea()
        }
    }
}

extension CalculatorInput {
    var color: Color {
        switch self {
        case .backspace, .clear, .percent, .invertSign:
            return .blue
        case .divide, .multiply, .subtract, .add, .equal:
            return .orange
        default:
            return .primary
        }
    }
    
    var label: some View {
        VStack {
            switch self {
            case .backspace:
                Image(systemName: "delete.backward")
            case .clear:
                Image(systemName: "c.square")
            case .percent:
                Image(systemName: "percent")
            case .divide:
                Image(systemName: "divide")
            case .multiply:
                Image(systemName: "multiply")
            case .subtract:
                Image(systemName: "minus")
            case .add:
                Image(systemName: "plus")
            case .invertSign:
                Image(systemName: "plus.forwardslash.minus")
            case .equal:
                Image(systemName: "equal")
            default:
                Text(self.rawValue)
            }
        }
    }
}

#Preview {
    ContentView()
}
