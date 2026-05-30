//
//  ContentView.swift
//  AdvancedTechniquesLab
//
//  Created by Tyson Pitcher on 5/15/26.
//
import Foundation
import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Login")
                .font(.title.bold())
                .padding(.top, 30)
            
            TextField("Username", text: $viewModel.userName)
                .padding()
                .modifier(LoginField())
            
            SecureField("Password", text: $viewModel.password)
                .padding()
                .modifier(LoginField())
            
            Button("Login") {
                Task {
                    viewModel.loginState = .loading
                    viewModel.loginState = await viewModel.login(
                        userName: viewModel.userName,
                        password: viewModel.password
                    )
                }
            }
            .buttonStyle(CustomButtonStyle())
            .padding()
            
            Section {
                switch viewModel.loginState {
                case .idle:
                    Text(viewModel.loginState.message)
                case .loading:
                    ProgressView()
                case .success:
                    Text(viewModel.loginState.message)
                case .error:
                    Text(viewModel.loginState.message)
                }
            }
            .padding()
        }
        .padding()
        Spacer()
    }
}


#Preview {
    ContentView()
}

