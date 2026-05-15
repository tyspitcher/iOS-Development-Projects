//
//  SupabaseConfig.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import Foundation

enum SupabaseConfig {
    static let projectURL = URL(string: "https://fdwpbyzosrcepjzeogxk.supabase.co")!
    static let publishableKey = "sb_publishable_q_Jo9CjhKIi0hnp4p47cSQ_dQQgZ1VG"

    static let restBaseURL = projectURL.appending(path: "/rest/v1")
    static let authBaseURL = projectURL.appending(path: "/auth/v1")
    static let storageBaseURL = projectURL.appending(path: "/storage/v1")

    static var publicHeaders: [String: String] {
        [
            "apikey": publishableKey,
            "Authorization": "Bearer \(publishableKey)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}
