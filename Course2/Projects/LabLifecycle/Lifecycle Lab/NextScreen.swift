//
//  NextScreen.swift
//  Lifecycle Lab
//
//  Created by Tyson Pitcher on 3/11/26.
//
import SwiftUI

struct NextScreenView: View {
    var body: some View {
        VStack {
            Image("funnyFace")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(20)
                
        }
    }
}

#Preview {
    NextScreenView()

}
