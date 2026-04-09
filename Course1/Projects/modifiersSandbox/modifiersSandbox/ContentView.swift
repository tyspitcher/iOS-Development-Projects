//
//  ContentView.swift
//  modifiersSandbox
//
//  Created by Tyson Pitcher on 2/23/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Button(action: next) {
            Text("Next")
                .frame(maxWidth: .infinity)
        }
        .foregroundStyle(.white)
        .padding(.vertical, 8)
        .background(
            Capsule().foregroundStyle(.gray)
)
        .padding()
    }
    
    func next() {
        
    }
}

#Preview {
    ContentView()
}
