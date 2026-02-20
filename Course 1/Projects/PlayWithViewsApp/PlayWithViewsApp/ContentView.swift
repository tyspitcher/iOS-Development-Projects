//
//  ContentView.swift
//  PlayWithViewsApp
//
//  Created by Tyson Pitcher on 2/19/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            Circle()
                .fill(Color.white)
                .frame(width: 2500, height: 2500)
                .offset(y: 1000)
        }
        .overlay(alignment: .topLeading) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 40, height: 40)
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tyson")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text("Pitcher")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .padding()
        }
    }
}
//    struct ContntView: View {
//    var body: some View {
//        ZStack {
//            HStack {
//                    Image(systemName: "person.fill")
//                        .imageScale(.large)
//                        .font(Font.largeTitle)
//                        .foregroundStyle(.tint)
//                        .padding()
//                    Text("Tyson Pitcher")
//                        .font(Font.largeTitle.bold())
//                
//                Spacer()
//            }
//        }
//        Spacer()
//
//            VStack(alignment: .leading) {
//                Image(systemName: "rectangle.and.pencil.and.ellipsis").imageScale(.large)
//                    .padding()
//            }
//            .frame(width: 50, height: 50)
//            .background(Color.blue)
//            Text("Posts: 102")
//            Spacer()
//            Spacer()
//    }
//}

#Preview {
    ContentView()
}
