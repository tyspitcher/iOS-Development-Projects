//
//  EditProfileView.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 3/31/26.
//
import SwiftUI
import Foundation
import Observation

import SwiftUI

struct EditProfileView: View {
    @State var viewModel: EditProfileViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("First Name", text: $viewModel.form.firstName)
                    TextField("Last Name", text: $viewModel.form.lastName)
                }
                Section("Username") {
                    TextField("Username", text: $viewModel.form.userName)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                Section("About Me") {
                    TextField("Bio", text: $viewModel.form.bio, axis: .vertical)
                }
                Section("Tech Interests") {
                    TextField("Tech Interests", text: $viewModel.form.techInterests, axis: .vertical)
                }
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await viewModel.save()
                            if viewModel.errorMessage == nil { dismiss() }
                        }
                    } label: {
                        if viewModel.isSaving {
                            ProgressView()
                        } else {
                            Text("Save")
                        }
                    }
                    .disabled(viewModel.isSaving)
                }
            }
        }
    }
}

// preview with dummy data
#Preview {
    EditProfileView(
        viewModel: EditProfileViewModel(
            user: tyson,
            service: MockUserProfileService()
        ) { _ in }
    )
}
