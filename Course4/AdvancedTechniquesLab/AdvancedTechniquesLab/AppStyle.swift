//
//  AppStyle.swift
//  AdvancedTechniquesLab
//
//  Created by Tyson Pitcher on 5/15/26.
//
import SwiftUI


struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .padding(.horizontal, 100)
            .background(configuration.isPressed ? Color.cyan : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .font(Font.body.bold())
    }
}

struct LoginField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 275, height: 25)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Color.blue.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
            .padding(7)
            .shadow(radius: 6)
    }
}

#Preview {
    ContentView()
}
