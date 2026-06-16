//
//  Post.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 4/8/26.
//
import Foundation
import Observation

// creating format for a post
struct Post: Identifiable, Codable, Equatable {
    let id: UUID
    let authorID: UUID
    let date: Date
    let content: String
}
