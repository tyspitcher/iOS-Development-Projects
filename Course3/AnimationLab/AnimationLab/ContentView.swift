//
//  ContentView.swift
//  AnimationLab
//
//  Created by Tyson Pitcher on 5/4/26.
//

import SwiftUI
enum Countdown {
    case three, two, one, go

    var image: Image {
        switch self {
        case .three:
            return Image(systemName: "3.circle.fill")
        case .two:
            return Image(systemName: "2.circle.fill")
        case .one:
            return Image(systemName: "1.circle.fill")
        case .go:
            return Image("go")
        }
    }

    var color: Color {
        switch self {
        case .three:
            return .black
        case .two:
            return .red
        case .one:
            return .yellow
        case .go:
            return .green
        }
    }
}

struct ContentView: View {
    @State var currentCountdown: Countdown = .three
    @State var shrinkImage = false
    @State var fadeImage = false
    
    var body: some View {
        VStack {
            Spacer()
            currentCountdown.image
                .resizable()
                .frame(width: 400, height: 400)
                .scaleEffect(shrinkImage ? 0.1 : 1)
                .opacity(fadeImage ? 1.0 : 0)
                .foregroundStyle(currentCountdown.color)
                .animation(.linear(duration: 0.5), value: shrinkImage)
                .animation(.linear(duration: 0.5), value: fadeImage)
                .padding()
            Spacer()
            
            Button("Start Game") {
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
    private func animate(countdown: Countdown) {
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
            if countdown == .go {
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

    
    private func nextCountdown(after countdown: Countdown) -> Countdown? {
        switch countdown {
        case .three: return .two
        case .two: return .one
        case .one: return .go
        case .go: return nil
        }
    }
}


#Preview {
    ContentView()
}
