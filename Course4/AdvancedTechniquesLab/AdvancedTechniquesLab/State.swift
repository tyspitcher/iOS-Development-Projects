//
//  State.swift
//  AdvancedTechniquesLab
//
//  Created by Tyson Pitcher on 5/15/26.
//
import Foundation
import SwiftUI
import Observation

@Observable
class ContentViewModel {
    var loginState: LoginState = .idle
    var userName = ""
    var password = ""

    let correctUsername = "User"
    let correctPassword = "password"

    func login(userName: String, password: String) async -> LoginState {
        if userName.isEmpty || password.isEmpty {
            return .idle
        }

        try? await Task.sleep(for: .seconds(2))

        if userName == correctUsername && password == correctPassword {
            return .success
        } else {
            return .error
        }
    }
}

enum LoginState {
    case idle
    case loading
    case success
    case error
    
    var message: String {
        switch self {
        case .idle:
            return "please enter username and password"
        case .success:
            return "login was successful"
        case .error:
            return "invalid or incorrect username or password, please try again"
        case .loading:
            return ""
        }
    }
}
#Preview {
    ContentView()
}
