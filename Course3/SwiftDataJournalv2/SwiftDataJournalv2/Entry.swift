//
//  Entry.swift
//  SwiftDataJournalv2
//
//  Created by Tyson Pitcher on 4/27/26.
//

import Foundation
import SwiftData

@Model
final class Entry {
    var id: String
    var title: String
    var body: String
    var createdAt: Date
    var updatedAt: Date
    var journal: Journal?
    
    init (title: String, body: String, journal: Journal? = nil) {
        self.id = UUID().uuidString
        self.title = title
        self.body = body
        self.createdAt = Date()
        self.updatedAt = Date()
        self.journal = journal
    }
}
