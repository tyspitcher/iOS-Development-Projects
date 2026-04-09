//
//  ContentView.swift
//  ErrorHandlingSandbox
//
//  Created by Tyson Pitcher on 3/23/26.
//

import SwiftUI

struct ContentView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    var body: some View {
        VStack {
            Text("Login").font(.largeTitle)
                .bold()
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            
            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
            
            Button("Login") {
               do {
                   try validateEmail(email)
                   try lookupUserNameAndPassword(email: email, password: password)
                    
                } catch {
                   print(error)
                    errorMessage = error.localizedDescription
               }
            }
            
        }
        .padding()
    }
    func lookupUserNameAndPassword(email: String, password: String) throws {
        try validateEmail(email)
        if !UserDatabase.users.contains(email) {
            throw ValidationError.userNotFound
        }
        
    }
    
    func validateEmail(_ email: String) throws {
        if !email.isValidEmail {
            throw ValidationError.invalidEmail
        }
    }
}

enum ValidationError: LocalizedError {
    case invalidEmail
    case userNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Invalid email address."
        case .userNotFound:
            return "We were unable to locate that email address. Please try again."
        }
    }
}
extension String {
    var isValidEmail: Bool {
        return false
    }
}

class UserDatabase {
    static let users: [String] = []
}
#Preview {
    ContentView()
}
