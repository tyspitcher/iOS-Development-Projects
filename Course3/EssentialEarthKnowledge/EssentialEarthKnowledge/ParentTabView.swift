//
//  ParentTabView.swift
//  EssentialEarthKnowledge
//
//  Created by Tyson Pitcher on 4/20/26.
//

import SwiftUI

struct ParentTabView: View {
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "globe.americas")
                    .font(.system(size: 30))
                    .foregroundStyle(.tint)
                Text(" Welcome to Earth")
                    .font(.title.bold())
                Image(systemName: "globe.europe.africa")
                    .font(.system(size: 30))
                    .foregroundStyle(.tint)
                    .padding(.horizontal, 8)
            }
        }

        NavigationStack {
            TabView {
                ETGoHomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                NameDogsView(photoController: DogAPIController())
                    .tabItem {
                        Label("Dogs", systemImage: "dog.fill")
                    }
                
                TakeMeToYourLeaderView(representativeController: .live)
                    .tabItem {
                        Label("Leaders", systemImage: "person")
                        
                    }
                NobelPrizeView(viewModel: NobelPrizeViewModel())
                    .tabItem {
                        Label("Nobel", systemImage: "brain.filled.head.profile")
                    }
            }
        }
    }
}


#Preview {
    ParentTabView()
}
