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
                    VStack(alignment: .leading, spacing: 22) {
                        availableToggle

                        filterSection(title: "Color") {
                            chipGrid {
                                optionalTextChip("Any", selection: $draftFilter.colorName, value: nil)
                                ForEach(appState.availableColors, id: \.self) { color in
                                    optionalTextChip(color, selection: $draftFilter.colorName, value: color)
                                }
                            }
                        }

                        filterSection(title: "Size") {
                            chipGrid {
                                optionalTextChip("Any", selection: $draftFilter.size, value: nil)
                                ForEach(appState.availableSizes, id: \.self) { size in
                                    optionalTextChip(size, selection: $draftFilter.size, value: size)
                                }
                            }
                        }

                        filterSection(title: "Category") {
                            chipGrid {
                                optionalChip("All", selection: $draftFilter.category, value: nil)
                                ForEach(ClothingCategory.allCases) { category in
                                    optionalChip(category.displayName, selection: $draftFilter.category, value: category)
                                }
                            }
                        }

                        filterSection(title: "Occasion") {
                            chipGrid {
                                optionalChip("Any", selection: $draftFilter.occasion, value: nil)
                                ForEach(OccasionCategory.allCases) { occasion in
                                    optionalChip(occasion.displayName, selection: $draftFilter.occasion, value: occasion)
                                }
                            }
                        }

                        filterSection(title: "Brand") {
                            chipGrid {
                                optionalTextChip("Any", selection: $draftFilter.brand, value: nil)
                                ForEach(appState.availableBrands, id: \.self) { brand in
                                    optionalTextChip(brand, selection: $draftFilter.brand, value: brand)
                                }
                            }
                        }

                        filterSection(title: "Relationship") {
                            chipGrid {
                                optionalChip("Any", selection: $draftFilter.relationship, value: nil)
                                ForEach(UserRelationship.allCases) { relationship in
                                    optionalChip(relationship.displayName, selection: $draftFilter.relationship, value: relationship)
                                }
                            }
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
                    .fontWeight(.semibold)
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
            VStack(alignment: .leading, spacing: 3) {
                Text("Available now")
                    .font(AppTheme.titleFont(size: 20))
                    .foregroundStyle(AppTheme.ink)

                Text("Only show pieces ready to request today.")
                    .font(AppTheme.bodyFont(size: 12))
                    .foregroundStyle(AppTheme.mutedInk)
            }
        }
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            SecondaryButton(title: "Reset", systemImage: "arrow.counterclockwise") {
                draftFilter = ThreadFilter()
                appState.applyFilter(draftFilter)
            }

            PrimaryButton(title: "Apply \(appState.filteredItems(matching: draftFilter).count)", systemImage: "checkmark") {
                appState.applyFilter(draftFilter)
                dismiss()
            }
        }
        .padding(.top, 4)
    }

    private var trailingToolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .topBarTrailing
        #else
        .automatic
        #endif
    }

    private func filterSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title)
            content()
        }
    }

    private func chipGrid<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 104), spacing: 9)],
            alignment: .leading,
            spacing: 9
        ) {
            content()
        }
    }

    private func optionalChip<Value: Equatable>(
        _ title: String,
        selection: Binding<Value?>,
        value: Value?
    ) -> some View {
        FilterChip(
            title: title,
            isSelected: selection.wrappedValue == value,
            action: { selection.wrappedValue = value }
        )
    }

    private func optionalTextChip(
        _ title: String,
        selection: Binding<String?>,
        value: String?
    ) -> some View {
        FilterChip(
            title: title,
            isSelected: selection.wrappedValue == value,
            action: { selection.wrappedValue = value }
        )
    }
}

struct FilterSheetView_Previews: PreviewProvider {
    static var previews: some View {
        FilterSheetView()
            .environmentObject(AppState())
    }
}
