//
//  SettingsSheetView.swift
//  DragonDex
//
//  Created by Logan Steven Bartell on 12/4/25.
//

import SwiftUI

struct SettingsSheetView: View {
    @Environment(BackgroundSettings.self) var backgroundSettings
    let backgroundColors: [Color] = [.red, .green, .yellow]
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .bold()
            Text("Background Color")
                    .padding()
            ForEach(backgroundColors, id: \.self) { color in
                colorButton(color: color)
            }
            Spacer()
        }
    }
    
    //Builder Views
    func colorButton(color: Color) -> some View {
        Button {
            backgroundSettings.backgroundColor = color
        } label: {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 250, height: 50)
                .foregroundStyle(color)
        }
    }
}

