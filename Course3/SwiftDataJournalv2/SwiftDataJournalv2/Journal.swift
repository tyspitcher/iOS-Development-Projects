//
//  Journal.swift
//  SwiftDataJournalv2
//
//  Created by Tyson Pitcher on 4/28/26.
//

import Foundation
import SwiftData

@Model
final class Journal {
    var id: String
    var createdAt: Date
    var title: String
    
    @Relationship(deleteRule: .cascade, inverse: \Entry.journal)
    var entries = [Entry]()
    
    init(title: String) {
        self.id = UUID().uuidString
        self.createdAt = Date()
        self.title = title
        self.entries = []
    }
}
