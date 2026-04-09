//
//  ContentView.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 3/30/26.
//

import SwiftUI
import Foundation

struct UserProfileView: View {
    @State var viewModel: UserProfileViewModel
    @State private var isPresentingEditProfile = false
    let user: UserProfile
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        Button { isPresentingEditProfile = true } label: {
                            Text("Edit Profile")
                                .font(.headline)
                                .background(.thinMaterial, in: Capsule())
                        }
                    }
                    .padding()
                    .padding(.horizontal)
                    
                    ZStack {
                        Image(viewModel.displayedUser.backgroundImage ?? "defaultBackground")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 169)
                            .clipped()
                            .ignoresSafeArea(edges: .horizontal)
                            .allowsHitTesting(false)
                        
                        Image(viewModel.displayedUser.profileImage ?? "user")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.primary, lineWidth: 6)
                            )
                            .offset(x: -125, y: 65)
                    }
                    .frame(maxWidth: .infinity, alignment: .bottomLeading)
                    .padding(.bottom)
                    
                    Text("\(viewModel.displayedUser.firstName) \(user.lastName)")
                        .font(Font.largeTitle.bold())
                        .foregroundStyle(Color.primary)
                        .padding(.horizontal, 30)
                    Text("@\(viewModel.displayedUser.userName)")
                        .padding(.bottom, 12)
                        .padding(.horizontal, 30)
                    
                    Text("About Me")
                        .font(.headline)
                        .padding(.horizontal, 30)
                    Text(viewModel.displayedUser.bio)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 12)
                    
                    Text("Tech Interests")
                        .font(.headline)
                        .padding(.horizontal, 30)
                    Text(viewModel.displayedUser.techInterests)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 12)
                    
                    Text("Recent Post")
                        .font(.headline)
                        .padding(.horizontal, 30)
                    if let recent = viewModel.recentPost {
                        Text(recent.content)
                            .padding(.horizontal, 30)
                            .padding(.bottom, 12)
                    } else {
                        Text("No recent posts")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 30)
                            .padding(.bottom, 12)
                    }
                    
                    Spacer()
                }
            }
            .sheet(isPresented: $isPresentingEditProfile) {
                EditProfileView(
                    viewModel: EditProfileViewModel(
                        user: viewModel.displayedUser,
                        onSave: { updated in
                            viewModel.displayedUser = updated
                        }
                    )
                )
            }
        }
    }
}
#Preview {
    UserProfileView(viewModel: UserProfileViewModel(user: tyson), user: tyson)
}

