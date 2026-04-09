//
//  ParentTabView.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 4/7/26.
//

import SwiftUI

struct ParentTabView: View {
    private let user = tyson

    // Hold the shared service as a simple constant
    private let postService: InMemoryPostService

    // View models initialized in init()
    @State private var userProfileViewModel: UserProfileViewModel
    @State private var timelineViewModel: TimelineViewModel

    init() {
        let service = InMemoryPostService(seedPosts: userPosts)
        self.postService = service

        _userProfileViewModel = State(initialValue: UserProfileViewModel(user: tyson))
        _timelineViewModel = State(initialValue: TimelineViewModel(postService: service))
    }

    var body: some View {
        VStack {
            HStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .padding(.horizontal, 30)
                Spacer()
            }
        }

        TabView {
            UserProfileView(viewModel: userProfileViewModel, user: user)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }

            TimelineView(viewModel: timelineViewModel, currentUserID: user.id)
                .tabItem {
                    Label("Timeline", systemImage: "calendar.day.timeline.left")
                }
        }
    }
}

#Preview {
    ParentTabView()
}
