//
//  UserAvatarView.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/6/26.
//

import SwiftUI

struct UserAvatarView: View {
    let imageName: String
    var size: CGFloat

    var body: some View {
        Group {
            if let localAvatarURL = ProfileAvatarStore.localAvatarURL(for: imageName) {
                AsyncImage(url: localAvatarURL) { phase in
                    switch phase {
                    case .empty:
                        placeholderAvatar
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholderAvatar
                    @unknown default:
                        placeholderAvatar
                    }
                }
            } else if let generatedAvatar = generatedAvatar {
                generatedAvatarView(generatedAvatar)
            } else if let remoteURL = remoteAvatarURL {
                AsyncImage(url: remoteURL) { phase in
                    switch phase {
                    case .empty:
                        placeholderAvatar
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholderAvatar
                    @unknown default:
                        placeholderAvatar
                    }
                }
            } else if looksLikeSystemSymbol {
                placeholderAvatar
            } else {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var looksLikeSystemSymbol: Bool {
        imageName.contains(".")
    }

    private var remoteAvatarURL: URL? {
        guard imageName.contains("/") else { return nil }
        return ProfileAvatarStore.publicAvatarURL(for: imageName)
    }

    private var generatedAvatar: GeneratedAvatar? {
        AvatarDescriptor.parseGenerated(imageName)
    }

    private var placeholderAvatar: some View {
        Image(systemName: imageName)
            .resizable()
            .scaledToFit()
            .padding(size * 0.2)
            .foregroundStyle(AppTheme.accent)
            .background(AppTheme.accentSoft)
    }

    private func generatedAvatarView(_ avatar: GeneratedAvatar) -> some View {
        let backgroundColor = Color(threadShareHex: avatar.colorHex)
        let textColor = AvatarDescriptor.contrastColor(for: avatar.colorHex)

        return ZStack {
            backgroundColor

            Text(avatar.initials)
                .font(.system(size: max(18, size * 0.4), weight: .bold, design: .rounded))
                .foregroundStyle(textColor)
        }
    }
}
