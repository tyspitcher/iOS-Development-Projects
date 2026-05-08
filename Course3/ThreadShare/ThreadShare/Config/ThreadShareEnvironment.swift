//
//  ThreadShareEnvironment.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/5/26.
//

import Foundation

enum ThreadShareEnvironment {
    // iOS app consumes backend API hosted on Render.
    static let backendBaseURL = URL(string: "https://threadshare.onrender.com")!

    // Reference metadata from the team stack (not directly consumed by iOS runtime):
    static let webFrontendURL = URL(string: "https://thread-share.vercel.app/")!
    static let railwayProjectURL = URL(string: "https://railway.com/project/08899281-e0a2-4fc9-a3da-020bc78cef8b?")!
}
