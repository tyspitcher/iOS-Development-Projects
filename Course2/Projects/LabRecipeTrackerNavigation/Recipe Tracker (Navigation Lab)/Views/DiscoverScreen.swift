//
//  DiscoverView.swift
//  Recipe Tracker (Navigation Lab)
//
//  Created by Jane Madsen on 10/8/25.
//

import SwiftUI

struct DiscoverScreen: View {
    let discoverRecipes = Recipe.discoverList
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    RecipeDetailScreen(recipe: discoverRecipes[0])
                } label: {
                    Text("Avocado Toast")
                }
                NavigationLink {
                    RecipeDetailScreen(recipe: discoverRecipes[1])
                } label: {
                    Text("Greek Salad")
                }
            }
            .navigationTitle("Discover")
        }
    }
}

#Preview {
    DiscoverScreen()
}
