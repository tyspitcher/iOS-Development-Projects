//
//  NewPostView.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 3/31/26.
//
import Foundation
import SwiftUI

struct NewPostView: View {
    @State var viewModel: NewPostViewModel
    let onSubmitSuccess: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Post title", text: $viewModel.title)
                }

                Section("Body") {
                    TextEditor(text: $viewModel.body)
                        .frame(minHeight: 160)
                }

                Section {
                    Button(viewModel.isSubmitting ? "Posting..." : "Submit Post") {
                        Task {
                            await viewModel.submitPost(onSuccess: onSubmitSuccess)
                        }
                    }
                    .disabled(!viewModel.canSubmit)
                }
            }
            .navigationTitle("New Post")
        }
    }
}
