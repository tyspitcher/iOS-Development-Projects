//
//  ContentView.swift
//  AnimationLab
//
//  Created by Tyson Pitcher on 5/4/26.
//

import SwiftUI
enum MakeGroup {
    case three, two, one

    var image: Image {
        switch self {
        case .three:
            return Image(systemName: "person.fill")
        case .two:
            return Image(systemName: "person.2.fill")
        case .one:
            return Image(systemName: "person.3.fill")
        }
    }
}

struct ContentView: View {
    @State var currentCountdown: MakeGroup = .three
    @State var shrinkImage = false
    @State var fadeImage = false
    @Namespace var animation
    
    var body: some View {
        
        VStack {
            Spacer()
            currentCountdown.image
                .resizable()
                .frame(width: 400, height: 400)
                .scaleEffect(shrinkImage ? 0.1 : 1)
                .opacity(fadeImage ? 1.0 : 0)
                .foregroundStyle(.black)
                .animation(.linear(duration: 0.5), value: shrinkImage)
                .animation(.linear(duration: 0.5), value: fadeImage)
                .padding()
            Spacer()
            
            Button("Make Group") {
                startCountdown()
            }
            .font(.title)
        }
        .padding()
    }
    
    func startCountdown() {
        currentCountdown = .three
        shrinkImage = false
        fadeImage = false
        animate(countdown: .three)
    }
    
    private func animate(countdown: MakeGroup) {
        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            currentCountdown = countdown
            shrinkImage = false
            fadeImage = false
        }

        withAnimation(.linear(duration: 0.5)) {
            fadeImage = true
            shrinkImage = true
        } completion: {
            if countdown == .one {
                fadeImage = true
                return
            }
        
            withAnimation(.linear(duration: 0.5)) {
                fadeImage = false
            } completion: {
                if let next = nextCountdown(after: countdown) {
                    animate(countdown: next)
                }
            }
        }
    }

    private func nextCountdown(after countdown: MakeGroup) -> MakeGroup? {
        switch countdown {
        case .three: return .two
        case .two: return .one
        case .one: return nil
        }
    }
}


#Preview {
    ContentView()
}
