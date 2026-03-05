//
//  SpaceshipScreen.swift
//  State Spaceship (aka Stateship)
//
//  Created by Jane Madsen on 9/29/25.
//

import SwiftUI

@Observable class ShipComputer {
    var availablePower = 10
    var heading = ""

}

struct SpaceshipScreen: View {
    @Environment(ShipComputer.self) var shipComputer
    var body: some View {

        Form {
            Section("Helm Station") {
                HelmStation()
            }
            
            Section("Weapons Station") {
                WeaponsStation()
            }
            
            Section("Shield Station") {
                ShieldStation()
            }
            
            Section("Engine Station") {
                EngineStation()
            }
            
            Text("Available Power: \(shipComputer.availablePower)")

        }
        .padding()
    }
}

struct HelmStation: View {
    @Environment(ShipComputer.self) private var shipComputer
    @State var inChair = false
    var body: some View {
        @Bindable var shipComputer = shipComputer
        HStack {
            CrewChair(crewMember: .dog, inChair: $inChair)
            
            TextField("Heading", text: $shipComputer.heading)
                .disabled(!inChair)
        }
    }
}

struct WeaponsStation: View {
    @Environment(ShipComputer.self) var shipComputer
    @State var isOn = false
    @State var inChair = false
    var body: some View {
        HStack {
            CrewChair(crewMember: .cat, inChair: $inChair)
            
            VStack {
                Toggle("Weapons Power: \(isOn ? 3 : 0)", isOn: $isOn)
                    .onChange(of: isOn) {
                        if isOn {
                            shipComputer.availablePower -= 3
                            if shipComputer.availablePower < 0 {
                                isOn = false
                                shipComputer.availablePower += 3
                            }
                        } else {
                            shipComputer.availablePower += 3
                        }
                    }

                //            .onChange(of: isOn) {
        
                //                // Add logic to remove/add 3 power to the system when enabled/disabled
                //            }
                
                Button("Fire!") {
                    if shipComputer.availablePower > 0 {
                        print("PEW!")
                    } else {
                        print("We need more power!")
                    }
                    // Add logic to only allow firing if power is available
                }
                .disabled(!isOn)
            }
            .disabled(!inChair)
            .onChange(of: inChair) { oldValue, newValue in
                if newValue == false {
                    isOn = false
                }
            }
        }
    }
}

struct ShieldStation: View {
    @Environment(ShipComputer.self) var shipComputer
    @State var powerUsed = 0
    @State var inChair = false
    var body: some View {
        HStack {
            CrewChair(crewMember: .lizard, inChair: $inChair)
            Stepper("Shield Power: \(powerUsed)", value: $powerUsed, in: 0...10)
                .onChange(of: powerUsed) { oldValue, newValue in
                    let diff = newValue - oldValue
                    shipComputer.availablePower -= diff
                    if shipComputer.availablePower < 0 {
                        powerUsed = oldValue
                    }
                }
                .disabled(!inChair)
        }
    }
}

struct EngineStation: View {
    @Environment(ShipComputer.self) var shipComputer
    @State var powerUsed = 0
    @State var inChair = false
    var body: some View {
        HStack {
            CrewChair(crewMember: .hare, inChair: $inChair)
            Stepper("Engine Power: \(powerUsed)", value: $powerUsed, in: 0...10)
                .onChange(of: powerUsed) { oldValue, newValue in
                    let diff = newValue - oldValue
                    shipComputer.availablePower -= diff
                    if shipComputer.availablePower < 0 {
                        powerUsed = oldValue
                    }
                }
                .disabled(!inChair)
        }
    }
}

struct CrewChair: View {
    
    var crewMember: Crew
    @Binding var inChair: Bool
    
    var body: some View {
        Button {
            inChair.toggle()
        } label: {
            if inChair {
                crewMember.icon
            } else {
                Image(systemName: "person.slash")
            }
        }
        .padding(5)
        .background {
            Circle()
                .foregroundStyle(.gray)
        }
    }
}

enum Crew: String {
    case dog
    case cat
    case lizard
    case hare
    
    var icon: Image {
        switch self {
        case .dog:
            Image(systemName: "dog")
        case .cat:
            Image(systemName: "cat")
        case .lizard:
            Image(systemName: "lizard")
        case .hare:
            Image(systemName: "hare")
        }
    }
}

#Preview {
    SpaceshipScreen()
        .environment(ShipComputer())
}
