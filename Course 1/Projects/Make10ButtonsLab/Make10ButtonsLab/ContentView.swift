//
//  ContentView.swift
//  Make10ButtonsLab
//
//  Created by Tyson Pitcher on 2/24/26.
//

import SwiftUI

struct GrievousButtonStyle: ButtonStyle {
    let grievousPresent: Bool

    func makeBody(configuration: Configuration) -> some View {
  
        let title = grievousPresent ? "Grievous Here" : "Grievous Gone"
        return Label {
            Text(title)
        } icon: {
            Image(systemName: grievousPresent ? "person.fill.checkmark" : "person.fill.xmark")
        }
        .padding(7)
        .frame(maxWidth: .infinity)
        .foregroundStyle(grievousPresent ? .green : .red)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(grievousPresent ? Color.green : Color.red, lineWidth: 3)
        )
    }
}

struct MonsterButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let symbolName = configuration.isPressed ? "rectangle.ratio.16.to.9" : "rectangle.ratio.9.to.16"
        return Label {
            Text("Drink Monster")
        } icon: {
            Image(systemName: symbolName)
        }
        .frame(maxWidth: .infinity)
        .padding(7)
        .font(.custom("Impact", size: 22))
        .foregroundStyle(.green)
        .background(.black)
    }
}

struct ContentView: View {
    
    @State var grievousIsPresent: Bool = true
    @State var clickedDoNotClick: Int = 21945
    @State private var mysteryOutput: String = ""
    
    var body: some View {
        Spacer()
        VStack {
            Text("DO NOT CLICK click count: \(clickedDoNotClick)")
                .padding()
            HStack {
                Button(action: { grievousIsPresent.toggle() }) {
                    EmptyView()
                }
                .buttonStyle(GrievousButtonStyle(grievousPresent: grievousIsPresent))
                
                Button("\"Hello there!\"", systemImage: "figure.baseball", action: fightGrievous)
                    .buttonStyle(.bordered)
                    .foregroundStyle(.black)
                    .disabled(!grievousIsPresent)
            }
                
            Button {
                mysteryOutput = doSomething()
            } label: {
                Text("Mystery Button???")
                    .font(.title)
                    .foregroundStyle(.yellow)
            }
            .buttonStyle(.borderedProminent)
            .padding()
 
            Button(action: drinkMonster) {
                EmptyView()
            }
            .buttonStyle(MonsterButtonStyle())
            
            Button(action: {
                clickedDoNotClick += 1
            }) {
                Text("⚠️ DO NOT CLICK ⚠️")
            }
            .frame(maxWidth: .infinity)
            .font(.custom("Futura", size: 35))
            .background(.red)
            .clipShape(Capsule())
            .foregroundStyle(.white)
        }
        
        .padding()
        
        HStack {
            Button(action: doNothing) {
                Text("Boring Button #1")
            }
            .buttonStyle(.plain)
            .font(.custom("Copperplate", size: 15))
            
            .padding()
            
            Button(action: doNothing) {
                Text("Boring Button #2")
            }
            .buttonStyle(.bordered)
            
           
        }
        Button(action: doNothing) {
            Image(systemName: "lizard.fill") // or any SF Symbol
                .font(.system(size: 80))
                .foregroundStyle(.green)
        }
        
        HStack {
            Button(action: doNothing) {
                Text("Boring Button #3")
            }
            .font(.custom("Chalkduster", size: 15))
            .frame(maxWidth: 175, maxHeight: 40)
            .background(.yellow)
            .foregroundStyle(.purple)
            
            .padding()
            
            Button(action: doNothing) {
                Text("Boring Button #4")
                    .font(.custom("Papyrus", size: 20))
                    .foregroundStyle(.brown)
            }
            .buttonStyle(.plain)
            .padding()
           
        }
        
        Spacer()
        Text(mysteryOutput)
            .padding()
    }
    
    func doSomething() -> String {
        let mysteryButtonOutputs: [String] = [
            "nothing happened",
            "ordered pizza, hope you love anchovies 🐟",
            "you have commenced the Apocalypse",
            "launch sequence activated",
            "somewhere a fairy just got its wings",
            "$20 has been sent to the charity of your choice",
            "you just solved world hunger, nice!",
            "you don't even want to know what just happened...",
            "you just triggered a time loop, now you're here again!",
            "you donated $1 to save a child",
            "the Oregon Trail just claimed another life",
            "Mike Tyson just gave your soul a little kith.",
            "somewhere Labron James just flopped on the ground and threw an adult tantrum"
        ]

        let randomIndex = Int.random(in: 0..<mysteryButtonOutputs.count)
        return mysteryButtonOutputs[randomIndex]
    }
    
    func doNothing() { }

    func fightGrievous() {
        print("Battle Grievous!")
    }

    func drinkMonster() {
        print("I feel energized!")
    }
}

#Preview {
    ContentView()
}
