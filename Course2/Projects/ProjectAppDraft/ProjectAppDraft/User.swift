//
//  UserProfile.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 4/8/26.
//
import Foundation
import Observation

// used to create and edit user profiles
struct User: Identifiable, Codable, Equatable {
    let id: UUID
    var firstName: String
    var lastName: String
    var userName: String
    var bio: String
    var techInterests: String
    var profileImage: String?
    var backgroundImage: String?
}
