//
//  ContentView.swift
//  GeometryReaderLab
//
//  Created by Tyson Pitcher on 5/13/26.
//

import SwiftUI

struct People {
    var image = Image(systemName: "person.crop.circle")
    var name: String
    var description: String
    var color: Color
}

extension People {
    static let tyson = People(name: "Tyson", description: "chill", color: .red)
    static let steph = People(name: "Steph", description: "organized", color: .pink)
    static let carson = People(name: "Carson", description: "curious", color: .blue)
    static let josie = People(name: "Josie", description: "independent", color: .purple)
    static let marley = People(name: "Marley", description: "resourceful", color: .yellow)
    static let kallie = People(name: "Kallie", description: "creative", color: .mint)
    static let quincey = People(name: "Quincey", description: "artistic", color: .teal)
}

struct ContentView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var peopleList: [People] = [.tyson, .steph, .carson, .josie, .marley, .kallie, .quincey]
    
    var columnCount: Int {
        print("\(horizontalSizeClass == .compact ? "compact" : "regular") - \(verticalSizeClass == .compact ? "compact" : "regular")")
        if horizontalSizeClass == .regular {
            return 4 // ipad landscape or portrait AND iPhone Max landscape
        } else { // horizontal == .compact
            if verticalSizeClass == .compact {
                return 3 // landscape on iPhone (not max)
            } else {
                return 2 // Portrait on all iPhone
            }
        }
    }
    
    var rowCount: Int {
        (peopleList.count / columnCount) + 1
        // Potentially take into account `% columncount == 0`
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                ForEach(0..<rowCount,id: \.self) { row in
                    HStack(alignment: .top) {
                        Spacer()
                        column(row: row)
                        Spacer()
                    }
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    func column(row: Int) -> some View {
        ForEach(0..<columnCount, id: \.self) { column in
            let index = row * columnCount + column
            if index < peopleList.count {
                let person = peopleList[index]
                personView(person)
            } else {
                Color.clear
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
    
//    @ViewBuilder
    func personView(_ person: People) -> some View {
        VStack() {
            person.image
                .resizable()
                .scaledToFit()
                .frame(height: 50)
                .foregroundStyle(person.color)
            Text(person.name)
                .font(.headline)
            Text(person.description)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    ContentView()
}
