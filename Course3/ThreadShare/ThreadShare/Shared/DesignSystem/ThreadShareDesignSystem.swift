//
//  ThreadShareDesignSystem.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import SwiftUI

struct ThreadShareLogoText: View {
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(AppTheme.accentSoft)

                Image(systemName: "hanger")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(AppTheme.accent)
            }
            .frame(width: 32, height: 32)

            Text("ThreadShare")
                .font(AppTheme.brandFont(size: 34))
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.ink)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("ThreadShare")
    }
}

struct PrimaryButton: View {
    let title: String
    var systemImage: String?
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            buttonLabel
                .font(AppTheme.bodyFont(size: 16))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(isDisabled ? AppTheme.softInk : AppTheme.accent, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                .shadow(color: isDisabled ? .clear : AppTheme.accent.opacity(0.22), radius: 12, x: 0, y: 7)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    @ViewBuilder
    private var buttonLabel: some View {
        if let systemImage {
            Label(title, systemImage: systemImage)
        } else {
            Text(title)
        }
    }
}

struct SecondaryButton: View {
    let title: String
    var systemImage: String?
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            buttonLabel
                .font(AppTheme.bodyFont(size: 16))
                .foregroundStyle(isDisabled ? AppTheme.softInk : AppTheme.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    @ViewBuilder
    private var buttonLabel: some View {
        if let systemImage {
            Label(title, systemImage: systemImage)
        } else {
            Text(title)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.bodyFont(size: 16))
                .foregroundStyle(isSelected ? AppTheme.selectedPillText : AppTheme.ink)
                .lineLimit(1)
                .padding(.horizontal, 15)
                .frame(height: 38)
                .background(isSelected ? AppTheme.selectedPillBackground : AppTheme.pillBackground, in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(isSelected ? AppTheme.strongBorder : AppTheme.pillBorder, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}

struct InfoChip: View {
    let title: String
    var systemImage: String?
    var tint: Color = AppTheme.ink

    var body: some View {
        HStack(spacing: 5) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption.weight(.bold))
            }

            Text(title)
                .lineLimit(1)
        }
        .font(AppTheme.bodyFont(size: 12))
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .frame(height: 30)
        .background(AppTheme.pillBackground, in: Capsule())
        .overlay(
            Capsule()
                .stroke(AppTheme.pillBorder, lineWidth: 1)
        )
    }
}

struct RecentlyAddedBadge: View {
    var title = "New"

    var body: some View {
        Label(title, systemImage: "sparkles")
            .font(AppTheme.bodyFont(size: 11).weight(.semibold))
            .foregroundStyle(AppTheme.selectedPillText)
            .lineLimit(1)
            .padding(.horizontal, 9)
            .frame(height: 26)
            .background(AppTheme.selectedPillBackground, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(AppTheme.strongBorder, lineWidth: 1)
            )
            .shadow(color: AppTheme.softShadow, radius: 8, x: 0, y: 4)
            .accessibilityLabel(title)
    }
}

struct AvailabilityBadge: View {
    let status: ItemAvailabilityStatus

    var body: some View {
        InfoChip(title: status.displayName, systemImage: iconName, tint: tint)
    }

    private var tint: Color {
        switch status {
        case .available: AppTheme.moss
        case .notAvailable: AppTheme.softInk
        case .requested: AppTheme.clay
        case .borrowed: AppTheme.accent
        }
    }

    private var iconName: String {
        switch status {
        case .available: "checkmark.circle.fill"
        case .notAvailable: "minus.circle.fill"
        case .requested: "clock.fill"
        case .borrowed: "bag.fill"
        }
    }
}

struct RelationshipBadge: View {
    let relationship: UserRelationship

    var body: some View {
        InfoChip(title: relationship.displayName, systemImage: iconName, tint: tint)
    }

    private var tint: Color {
        switch relationship {
        case .friend: AppTheme.accent
        case .follower: AppTheme.moss
        case .publicUser: AppTheme.mutedInk
        }
    }

    private var iconName: String {
        switch relationship {
        case .friend: "person.2.fill"
        case .follower: "person.crop.circle.badge.checkmark"
        case .publicUser: "globe.americas.fill"
        }
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    var systemImage: String = "sparkles"
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 64, height: 64)
                .background(AppTheme.accentSoft, in: Circle())

            VStack(spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.mutedInk)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let actionTitle, let action {
                SecondaryButton(title: actionTitle, systemImage: "arrow.counterclockwise", action: action)
                    .frame(maxWidth: 220)
                    .padding(.top, 4)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }
}

struct ThreadShareDesignSystem_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ThreadShareLogoText()

                PrimaryButton(title: "Request to Borrow", systemImage: "bag.badge.plus") {}
                SecondaryButton(title: "View Closet", systemImage: "hanger") {}

                HStack {
                    FilterChip(title: "Dresses", isSelected: true) {}
                    FilterChip(title: "Shoes", isSelected: false) {}
                }

                HStack {
                    AvailabilityBadge(status: .available)
                    RelationshipBadge(relationship: .friend)
                    InfoChip(title: "Game Day", systemImage: "star.fill", tint: AppTheme.clay)
                }

                EmptyStateView(
                    title: "No pieces here yet",
                    message: "Try clearing filters or checking back after friends add more closet finds.",
                    actionTitle: "Reset Filters",
                    action: {}
                )
            }
            .padding(AppTheme.pagePadding)
        }
        .background(AppTheme.background)
    }
}
