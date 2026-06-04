//
//  FilterSheetView.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import SwiftUI

struct FilterSheetView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var draftFilter: ThreadFilter

    init() {
        _draftFilter = State(initialValue: ThreadFilter())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.sectionSpacing) {
                        availableToggle

                        pickerSection(title: "Color") {
                            compactOptionalPicker(title: "Color", selection: $draftFilter.colorName, options: [
                                ("Any", nil)
                            ] + appState.availableColors.map { ($0, Optional($0)) })
                        }

                        pickerSection(title: "Size") {
                            compactOptionalPicker(title: "Size", selection: $draftFilter.size, options: [
                                ("Any", nil)
                            ] + appState.availableSizes.map { ($0, Optional($0)) })
                        }

                        pickerSection(title: "Category") {
                            compactOptionalPicker(title: "Category", selection: $draftFilter.category, options: [
                                ("All", nil)
                            ] + ClothingCategory.allCases.map { ($0.displayName, Optional($0)) })
                        }

                        pickerSection(title: "Occasion") {
                            compactOptionalPicker(title: "Occasion", selection: $draftFilter.occasion, options: [
                                ("Any", nil)
                            ] + OccasionCategory.allCases.map { ($0.displayName, Optional($0)) })
                        }

                        pickerSection(title: "Brand") {
                            compactOptionalPicker(title: "Brand", selection: $draftFilter.brand, options: [
                                ("Any", nil)
                            ] + appState.availableBrands.map { ($0, Optional($0)) })
                        }

                        pickerSection(title: "Relationship") {
                            compactOptionalPicker(title: "Relationship", selection: $draftFilter.relationship, options: [
                                ("Any", nil)
                            ] + UserRelationship.allCases.map { ($0.displayName, Optional($0)) })
                        }

                        actionButtons
                    }
                    .padding(AppTheme.pagePadding)
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: trailingToolbarPlacement) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(AppTheme.bodyFont(size: 14, weight: .semibold))
                }
            }
            .onAppear {
                draftFilter = appState.threadFilter
            }
        }
        #if os(iOS)
        .presentationDetents([.large])
        #endif
    }

    private var availableToggle: some View {
        Toggle(isOn: $draftFilter.availableNowOnly) {
            VStack(alignment: .leading, spacing: AppTheme.xSmallSpacing) {
                Text("Available now")
                    .font(AppTheme.titleFont(size: 18))
                    .foregroundStyle(AppTheme.ink)

                Text("Only show pieces ready to request today.")
                    .font(AppTheme.bodyFont(size: 12))
                    .foregroundStyle(AppTheme.mutedInk)
            }
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }

    private var actionButtons: some View {
        HStack(spacing: AppTheme.tightSpacing) {
            SecondaryButton(title: "Reset", systemImage: "arrow.counterclockwise") {
                draftFilter = ThreadFilter()
                appState.applyFilter(draftFilter)
            }

            PrimaryButton(title: "Apply \(appState.filteredItems(matching: draftFilter).count)", systemImage: "checkmark") {
                appState.applyFilter(draftFilter)
                dismiss()
            }
        }
        .padding(.top, AppTheme.microSpacing)
    }

    private var trailingToolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .topBarTrailing
        #else
        .automatic
        #endif
    }

    private func pickerSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.tightSpacing) {
            SectionTitle(title)
            content()
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }

    private func compactOptionalPicker<Value: Hashable>(
        title: String,
        selection: Binding<Value?>,
        options: [(String, Value?)]
    ) -> some View {
        Picker(title, selection: selection) {
            ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                Text(option.0).tag(option.1)
            }
        }
        .pickerStyle(.menu)
        .tint(AppTheme.accent)
        .font(AppTheme.bodyFont(size: 15, weight: .medium))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct FilterSheetView_Previews: PreviewProvider {
    static var previews: some View {
        FilterSheetView()
            .environmentObject(AppState())
    }
}
