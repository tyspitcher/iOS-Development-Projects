//
//  DateFormatter.swift
//  SwiftDataJournalv2
//
//  Created by Tyson Pitcher on 4/27/26.
//

import Foundation

var relativeDateFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.dateTimeStyle = .named
    return formatter
}()
