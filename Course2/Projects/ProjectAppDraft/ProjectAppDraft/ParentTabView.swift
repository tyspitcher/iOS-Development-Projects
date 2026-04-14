//
//  ParentTabView.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 4/7/26.
//
import SwiftUI
import Foundation

struct ParentTabView: View {
    @State var viewModel: ParentTabViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 165)
                
                Spacer()
            }
            Text("Space for Humans in The Loop")
                .italic()
                .font(.title3)
                .bold()
        }
        .padding(.horizontal, 30)
        NavigationStack {
            TabView {
                UserProfileView(viewModel: viewModel.userProfileViewModel)
                    .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                
                TimelineView(viewModel: viewModel.timelineViewModel, currentUserID: viewModel.user.id)
                    .tabItem { Label("Timeline", systemImage: "list.bullet.rectangle") }
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.presentNewPost()
                    } label: {
                        Label("New Post", systemImage: "square.and.pencil")
                    }
                }
            }
            
            .sheet(isPresented: $viewModel.isPresentingNewPost) {
                NewPostView(viewModel: viewModel.newPostViewModel) {
                    viewModel.dismissNewPost()
                }
            }
        }
    }
}

#Preview {
    ParentTabView(viewModel: ParentTabViewModel(user: tyson))
}
