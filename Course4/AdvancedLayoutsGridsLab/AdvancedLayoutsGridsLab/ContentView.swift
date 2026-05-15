//
//  ContentView.swift
//  AdvancedLayoutsGridsLab
//
//  Created by Tyson Pitcher on 5/14/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        let hatList = Clothing.hats
        let shirtList = Clothing.shirts
        let pantList = Clothing.pants
        GeometryReader { geometry in
            ScrollView {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(
                            rows: [
                                GridItem(.adaptive(minimum: 100, maximum: 100))
                            ]
                        ) {
                            ForEach(hatList, id: \.self) { hats in
                                ItemView(item: hats, width: 150, height: 150)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                } header: {
                    Text("Hats")
                        .font(.title)
                        .bold()
                        .padding(.top, 25)
                }
                
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(
                            rows: [
                                GridItem(.fixed(115)),
                                GridItem(
                                    .fixed(115))
                            ]
                        ) {
                            ForEach(shirtList, id: \.self) { shirts in
                                ItemView(item: shirts, width: 150, height: 150)
                            }
                        }
                        .scrollTargetLayout()
                    }
                } header: {
                    Text("Shirts")
                        .font(.title)
                        .bold()
                        .padding(.top, 25)
                }
                
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(
                            rows: [
                                GridItem(.adaptive(minimum: 50)),
                                GridItem(.adaptive(minimum: 50)),
                                GridItem(.adaptive(minimum: 50)),
                                GridItem(.adaptive(minimum: 50))
                            ]
                        ) {
                            ForEach(pantList, id: \.self) { pants in
                                ItemView(item: pants, width: 125, height: 125)
                            }
                        }
                        .scrollTargetLayout()
                    }
                } header: {
                    Text("Pants")
                        .font(.title)
                        .bold()
                        .padding(.top, 25)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
