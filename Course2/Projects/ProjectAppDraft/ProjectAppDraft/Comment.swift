//
//  Comment.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 4/8/26.
//
import Foundation
import SwiftUI
import Observation

// creating a format for a comment
struct Comment: Identifiable, Codable, Equatable {
    let id: UUID
    let postID: UUID
    let authorID: UUID
    let date: Date
    let content: String
}
