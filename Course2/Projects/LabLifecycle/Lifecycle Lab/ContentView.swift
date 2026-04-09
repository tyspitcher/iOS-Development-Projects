//
//  ContentView.swift
//  Lifecycle Lab
//
//  Created by Tyson Pitcher on 3/11/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @State var text: String = "event"
    var body: some View {
        NavigationStack {
            VStack {
            
                Spacer()
                Image(systemName: "figure.badminton")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .font(.largeTitle)
                Text(text)
                    .onChange(of: scenePhase) { _, newPhase in
                        if newPhase == .inactive {
                            text.append("\n inactive")
                        } else if newPhase == .active {
                            text.append("\n active")
                        } else if newPhase == .background {
                            text.append("\n app background")
                        }
                    }
                    .font(.largeTitle)
                Spacer()
                NavigationLink {
                    NextScreenView()
                } label: {
                    Text("next screen")
                }
            }
            
            .padding()
            .onAppear {
                text.append("\n on appear")
            }
            .onDisappear {
                text.append("\n on disappear")
            }
        }
    }
}

#Preview {
    ContentView()
}
