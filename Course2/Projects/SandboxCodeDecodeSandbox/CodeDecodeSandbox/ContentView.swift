//
//  ContentView.swift
//  CodeDecodeSandbox
//
//  Created by Tyson Pitcher on 3/24/26.
//

import SwiftUI
import Foundation
struct Note: Codable {
    let title: String
    let text: String
    let timestamp: Date
}

let newNote = Note(title: "Hello", text: "Note from today", timestamp: Date())

let encoder = PropertyListEncoder()
let encodedNote = try! encoder.encode(newNote)

// Save file
//let propertyListEncoder = PropertyListEncoder()



let decoder = PropertyListDecoder()
let decodedNote = try! decoder.decode(Note.self, from: encodedNote)

print(decodedNote)
