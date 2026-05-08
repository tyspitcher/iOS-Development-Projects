//
//  SectionTitle.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import SwiftUI

struct SectionTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(AppTheme.titleFont(size: 22))
            .foregroundStyle(AppTheme.ink)
    }
}
