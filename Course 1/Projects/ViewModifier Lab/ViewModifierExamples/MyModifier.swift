//
//  MyModifier.swift
//  ViewModifierExamples
//
//  Created by Toby Youngberg on 9/15/25.
//

import SwiftUI

struct MyModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .padding(5)
    }
}

extension View {
    func myModifier() -> some View {
        modifier(MyModifier())
    }
}

struct RedBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(15)
            .background(.red)
    }
}

extension View {
    func redBackground() -> some View {
        modifier(RedBackground())
    }
}

#Preview {
    MyView()
}

struct MakeHeading: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxHeight: .infinity, alignment: .top)
            .font(.largeTitle)
    }
}

extension View {
    func makeHeading() -> some View {
        modifier(MakeHeading())
    }
}
