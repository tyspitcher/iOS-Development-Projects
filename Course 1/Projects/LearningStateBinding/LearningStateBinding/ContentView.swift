//
//  ContentView.swift
//  LearningStateBinding
//
//  Created by Tyson Pitcher on 2/20/26.
//

import SwiftUI

@Observable
final class Account {
    var username: String? = nil

    func login() { username = "Kevin" }
    func logout() { username = nil }
        
}

struct RootView: View {
    let account = Account()
        
    var body: some View {
        NavigationStack {
            LevelOneView()
                .environment(account)
            Text(account.username ?? "Not logged in")
        }
    }
}

struct LevelOneView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Level 1")
            NavigationLink("Go deeper") {
                LevelTwoView()
            }
        }
        .padding()
    }
}

struct LevelTwoView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Level 2")
            LevelThreeView()
        }
        .padding()
        .background { Color.green }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct LevelThreeView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Level 3")
            AccountPanel()
        }
        .padding()
        .background { Color.blue }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

@Environment struct AccountPanel: View {

    private var account = Account()

    var body: some View {
        VStack(spacing: 12) {
            Text(account.username ?? "Not logged in")

            Button("Login") {
                account.login()
            }

            Button("Logout") {
                account.logout()
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    RootView()
}
