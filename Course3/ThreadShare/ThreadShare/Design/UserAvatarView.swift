//
//  UserAvatarView.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/6/26.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct UserAvatarView: View {
    let imageName: String
    var size: CGFloat

    var body: some View {
        Group {
            if hasAssetImage {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.2)
                    .foregroundStyle(AppTheme.accent)
                    .background(AppTheme.accentSoft)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var hasAssetImage: Bool {
        #if canImport(UIKit)
        UIImage(named: imageName) != nil
        #else
        false
        #endif
    }
}
