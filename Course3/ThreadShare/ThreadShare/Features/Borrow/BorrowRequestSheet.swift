//
//  BorrowRequestSheet.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import SwiftUI

struct BorrowRequestSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let item: ThreadItem
    let owner: UserProfile?
    var onRequestSent: () -> Void = {}

    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    @State private var message = "Would love to borrow this for an upcoming look."
    @State private var showDateError = false

    private var isDateRangeValid: Bool {
        endDate > startDate
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.sectionSpacing) {
                        itemSummary

                        VStack(spacing: AppTheme.tightSpacing) {
                            DatePicker("Borrow date", selection: $startDate, displayedComponents: .date)
                                .onChange(of: startDate) { _, newValue in
                                    if endDate <= newValue {
                                        endDate = Calendar.current.date(byAdding: .day, value: 1, to: newValue) ?? newValue
                                    }
                                    showDateError = false
                                }

                            DatePicker("Return date", selection: $endDate, displayedComponents: .date)
                                .onChange(of: endDate) { _, _ in
                                    showDateError = false
                                }
                        }
                        .font(AppTheme.bodyFont(size: 15))
                        .padding(AppTheme.cardPadding)
                        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))

                        if showDateError {
                            Label("Return date must be after the borrow date.", systemImage: "exclamationmark.circle.fill")
                                .font(AppTheme.bodyFont(size: 12))
                                .foregroundStyle(AppTheme.accent)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Message")
                                .font(AppTheme.titleFont(size: 20))
                                .foregroundStyle(AppTheme.ink)

                            TextEditor(text: $message)
                                .frame(minHeight: 110)
                                .padding(10)
                                .scrollContentBackground(.hidden)
                                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                                        .stroke(AppTheme.border, lineWidth: 1)
                                )
                        }

                        PrimaryButton(title: "Confirm Request", systemImage: "paperplane.fill") {
                            confirmRequest()
                        }
                    }
                    .padding(AppTheme.pagePadding)
                }
            }
            .navigationTitle("Borrow Request")
            .toolbar {
                ToolbarItem(placement: trailingToolbarPlacement) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(AppTheme.bodyFont(size: 14, weight: .semibold))
                }
            }
        }
        #if os(iOS)
        .presentationDetents([.medium, .large])
        #endif
    }

    private var itemSummary: some View {
        HStack(spacing: 14) {
            TileImageFallback(item: item)
                .frame(width: 86, height: 104)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))

            VStack(alignment: .leading, spacing: AppTheme.xSmallSpacing) {
                Text(item.title)
                    .font(AppTheme.titleFont(size: 20))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(2)

                Text(owner.map { "From \($0.displayName)" } ?? "From item owner")
                    .font(AppTheme.bodyFont(size: 15))
                    .foregroundStyle(AppTheme.mutedInk)
                    .lineLimit(1)

                Text("\(item.brand) | \(item.size)")
                    .font(AppTheme.bodyFont(size: 12, weight: .medium))
                    .foregroundStyle(AppTheme.softInk)

                AvailabilityBadge(status: item.availabilityStatus)
            }

            Spacer(minLength: 0)
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .shadow(color: AppTheme.softShadow, radius: 12, x: 0, y: 8)
    }

    private func confirmRequest() {
        guard isDateRangeValid else {
            showDateError = true
            return
        }

        let request = appState.requestToBorrow(
            itemID: item.id,
            startDate: startDate,
            endDate: endDate,
            message: message
        )

        guard request != nil else { return }

        dismiss()
        onRequestSent()
    }

    private var trailingToolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .topBarTrailing
        #else
        .automatic
        #endif
    }
}
