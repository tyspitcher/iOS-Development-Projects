//
//  SupabaseConfig.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import Foundation

enum SupabaseConfig {
    private static let defaultProjectURL = URL(string: "https://fdwpbyzosrcepjzeogxk.supabase.co")!
    private static let defaultPublishableKey = "sb_publishable_q_Jo9CjhKIi0hnp4p47cSQ_dQQgZ1VG"

    static var projectURL: URL {
        if
            let override = ProcessInfo.processInfo.environment["THREADSHARE_SUPABASE_URL"],
            let url = URL(string: override)
        {
            return url
        }

        if
            let override = UserDefaults.standard.string(forKey: "THREADSHARE_SUPABASE_URL"),
            let url = URL(string: override)
        {
            return url
        }

        return defaultProjectURL
    }

    static var publishableKey: String {
        if let override = ProcessInfo.processInfo.environment["THREADSHARE_SUPABASE_PUBLISHABLE_KEY"], override.isEmpty == false {
            return override
        }

        if let override = UserDefaults.standard.string(forKey: "THREADSHARE_SUPABASE_PUBLISHABLE_KEY"), override.isEmpty == false {
            return override
        }

        return defaultPublishableKey
    }

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
