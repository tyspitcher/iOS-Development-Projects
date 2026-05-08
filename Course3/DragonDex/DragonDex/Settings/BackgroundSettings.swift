//
//  BackgroundSettings.swift
//  DragonDex
//
//  Created by Logan Steven Bartell on 12/4/25.
//
import Foundation
import SwiftUI

@Observable
class BackgroundSettings {
    var backgroundColor: Color = .red
    
    func changeColor(color: Color) {
        backgroundColor = color
    }
}

