//
//  ThreadShareFontRegistrar.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/6/26.
//

import CoreText
import Foundation

enum ThreadShareFontRegistrar {
    static func registerFonts() {
        registerFont(named: "PlayfairDisplay-VariableFont_wght")
        registerFont(named: "Inter-VariableFont_opsz,wght")
    }

    private static func registerFont(named resourceName: String) {
        let fontURL = Bundle.main.url(forResource: resourceName, withExtension: "ttf") ??
            Bundle.main.url(forResource: resourceName, withExtension: "ttf", subdirectory: "Fonts")

        guard let fontURL else { return }

        _ = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
    }
}
