//
//  FashionPreferenceSelectionView.swift
//  ThreadShare
//
//  Created by Codex on 5/22/26.
//

import SwiftUI

struct FashionPreferenceSelectionView: View {
    @Binding var selection: FashionPreferenceSelection
    @Binding var customBrandEntry: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            styleSection
            brandSection
            colorPaletteSection
        }
    }

    var styleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeading(
                title: "Style Interests",
                subtitle: "Pick the looks you naturally reach for most."
            )

            chipWrap(
                values: FashionPreferenceCatalog.styles.map(\.id)
            ) { styleID in
                SelectablePreferenceChip(
                    title: FashionPreferenceCatalog.displayName(forStyleID: styleID),
                    isSelected: selection.styleIDs.contains(styleID)
                ) {
                    selection.toggleStyle(styleID)
                }
            }
        }
    }

    var brandSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(
                title: "Favorite Brands",
                subtitle: "Suggested brands update from your selected styles. Add your own too."
            )

            if selection.favoriteBrands.isEmpty == false {
                chipWrap(values: selection.favoriteBrands) { brand in
                    RemovablePreferenceChip(title: brand) {
                        selection.removeBrand(brand)
                    }
                }
            }

            if selection.suggestedBrandNames.isEmpty == false {
                chipWrap(values: selection.suggestedBrandNames) { brand in
                    SelectablePreferenceChip(
                        title: brand,
                        isSelected: selection.favoriteBrands.contains(brand)
                    ) {
                        selection.toggleBrand(brand)
                    }
                }
            } else {
                Text("Choose at least one style to unlock brand suggestions.")
                    .font(AppTheme.bodyFont(size: 13))
                    .foregroundStyle(AppTheme.mutedInk)
            }

            HStack(spacing: 10) {
                TextField("Add custom brand", text: $customBrandEntry)
                    .font(AppTheme.bodyFont(size: 15))
                    .textInputAutocapitalization(.words)
                    .padding(.horizontal, 14)
                    .frame(minHeight: 44)
                    .background(AppTheme.background, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
                    .onSubmit(addCustomBrand)
                    .accessibilityLabel("Add custom brand")
                    .accessibilityHint("Enter a brand name, then add it to your favorites.")

                Button("Add", action: addCustomBrand)
                    .font(AppTheme.bodyFont(size: 14).weight(.semibold))
                    .foregroundStyle(customBrandEntry.trimmed.isEmpty ? AppTheme.softInk : AppTheme.ink)
                    .frame(width: 64, height: 44)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
                    .disabled(customBrandEntry.trimmed.isEmpty)
                    .accessibilityHint("Adds the entered brand to your favorites.")
            }
        }
    }

    var colorPaletteSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeading(
                title: "Color Palettes",
                subtitle: "Save the color moods you want the app to learn from later."
            )

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 10)], spacing: 10) {
                ForEach(FashionPreferenceCatalog.colorPalettes) { palette in
                    ColorPaletteCard(
                        palette: palette,
                        isSelected: selection.colorPaletteIDs.contains(palette.id)
                    ) {
                        selection.toggleColorPalette(palette.id)
                    }
                }
            }
        }
    }

    private func addCustomBrand() {
        let value = customBrandEntry.trimmed
        guard value.isEmpty == false else { return }
        selection.addCustomBrand(value)
        customBrandEntry = ""
    }

    private func sectionHeading(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppTheme.bodyFont(size: 12))
                .foregroundStyle(AppTheme.accent)
                .textCase(.uppercase)

            Text(subtitle)
                .font(AppTheme.bodyFont(size: 13))
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private func chipWrap<Value: Hashable, Content: View>(
        values: [Value],
        @ViewBuilder content: @escaping (Value) -> Content
    ) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(values, id: \.self) { value in
                content(value)
            }
        }
    }
}

struct SelectablePreferenceChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13, weight: .semibold))
                }
            }
            .font(AppTheme.bodyFont(size: 14))
            .foregroundStyle(isSelected ? AppTheme.selectedPillText : AppTheme.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 44, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? AppTheme.selectedPillBackground : AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                    .stroke(isSelected ? AppTheme.strongBorder : AppTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint("Double tap to \(isSelected ? "remove" : "add") this style or brand.")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct RemovablePreferenceChip: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12, weight: .semibold))
            }
            .font(AppTheme.bodyFont(size: 13))
            .foregroundStyle(AppTheme.ink)
            .padding(.horizontal, 12)
            .frame(minHeight: 44)
            .background(AppTheme.accentSoft, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(AppTheme.strongBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint("Double tap to remove this favorite brand.")
    }
}

struct ColorPaletteCard: View {
    let palette: FashionColorPalette
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    ForEach(Array(palette.colorHexes.prefix(4)), id: \.self) { hex in
                        Circle()
                            .fill(Color(threadShareHex: hex))
                            .frame(width: 20, height: 20)
                            .overlay(Circle().stroke(Color.black.opacity(0.06), lineWidth: 1))
                    }

                    Spacer(minLength: 8)

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AppTheme.ink)
                    }
                }

                Text(palette.displayName)
                    .font(AppTheme.bodyFont(size: 14))
                    .foregroundStyle(AppTheme.ink)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(isSelected ? AppTheme.clay.opacity(0.22) : AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                    .stroke(isSelected ? AppTheme.clay.opacity(0.5) : AppTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(palette.displayName)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint("Double tap to \(isSelected ? "remove" : "add") this color palette.")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
