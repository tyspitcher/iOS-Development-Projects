//
//  ContentView.swift
//  PlayWithViewsApp
//
//  Created by Tyson Pitcher on 2/19/26.
//

import SwiftUI

struct ContentView: View {
    
    let hobbies = ["snowboarding", "digital art", "app building", "playing board games", "listening to music"]
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.cyan)
                    .frame(width: 70)
                Image(systemName: "person.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Tyson Pitcher")
                    .font(.largeTitle.bold())
                    .foregroundColor(.blue)
                Text("Swift Developer")
                    .font(.title.bold())
                    .foregroundColor(.blue)
            }
            .padding()
        }
        HStack{
            VStack{
                Image(systemName: "lizard")
                    .font(.title)
                    .foregroundStyle(.green)
                Text("Lizard")
                    .foregroundStyle(.black)
                
            }
            VStack{
                Image(systemName: "dog")
                    .font(.title)
                    .foregroundStyle(.brown)
                Text("Dog")
                    .foregroundStyle(.black)
                
            }
            VStack{
                Image(systemName: "tortoise")
                    .font(.title)
                    .foregroundStyle(.green)
                Text("Turtle")
                    .foregroundStyle(.black)
                
            }
            VStack{
                Image(systemName: "fish")
                    .font(.title)
                    .foregroundStyle(.yellow)
                Text("Fish")
                    .foregroundStyle(.black)
                
            }
            VStack{
                Image(systemName: "tree")
                    .font(.title)
                    .foregroundStyle(.green)
                Text("Tree")
                    .foregroundStyle(.black)
                
            }
            .padding()
        }
        VStack(alignment: .leading) {
            Text("Favorite Hobbies:")
                .font(.largeTitle.bold())
                .padding()
            ForEach(hobbies, id:\.self) { hobby in Text(hobby)
                    .font(.largeTitle)
                    .foregroundStyle(.black)
            }
        }
        Spacer()
        
        ZStack {
            Rectangle()
                .fill(Color.blue)
                .frame(width: 300, height: 100)
            Text("Follow")
                .foregroundStyle(.white)
                .font(.largeTitle)


        }
    }
}
    
    #Preview {
        ContentView()
    }
