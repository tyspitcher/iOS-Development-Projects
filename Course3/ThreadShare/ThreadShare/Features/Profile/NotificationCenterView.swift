//
//  NotificationCenterView.swift
//  ThreadShare
//
//  Created by Codex on 5/27/26.
//

import SwiftUI

private struct NotificationEntry: Identifiable {
    let id: UUID
    let notification: ThreadNotification
    let displayTitle: String
    let displayBody: String
    let unreadCount: Int
    let groupedCount: Int
    let groupedNotificationIDs: [ThreadNotification.ID]

    var isGroupedDirectMessage: Bool {
        notification.kind == .directMessage && groupedCount > 1
    }
}

struct NotificationCenterView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var pushPermissionManager: PushNotificationPermissionManager

    private var groupedNotifications: [(String, [NotificationEntry])] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: notificationEntries) { entry in
            let notification = entry.notification
            if calendar.isDateInToday(notification.createdAt) {
                return "Today"
            }
            if calendar.isDateInYesterday(notification.createdAt) {
                return "Yesterday"
            }
            return notification.createdAt.formatted(date: .abbreviated, time: .omitted)
        }

        return groups
            .map { key, notifications in
                (
                    key,
                    notifications.sorted { $0.notification.createdAt > $1.notification.createdAt }
                )
            }
            .sorted { lhs, rhs in
                (lhs.1.first?.notification.createdAt ?? .distantPast) > (rhs.1.first?.notification.createdAt ?? .distantPast)
            }
    }

    private var notificationEntries: [NotificationEntry] {
        let sorted = appState.notifications.sorted { $0.createdAt > $1.createdAt }
        let groupedDirectMessages = Dictionary(grouping: sorted.filter { $0.kind == .directMessage }) { notification in
            notification.actorID ?? UUID()
        }
        var consumedDirectMessageIDs = Set<ThreadNotification.ID>()
        var entries: [NotificationEntry] = []

        for notification in sorted {
            if notification.kind == .directMessage {
                guard let actorID = notification.actorID else {
                    entries.append(makeSingleEntry(from: notification))
                    continue
                }
                guard consumedDirectMessageIDs.contains(notification.id) == false else { continue }
                let actorNotifications = (groupedDirectMessages[actorID] ?? [notification]).sorted { $0.createdAt > $1.createdAt }
                let unreadCount = actorNotifications.filter { !$0.isRead }.count
                let latest = actorNotifications[0]
                let senderName = userDisplayName(for: actorID)
                entries.append(
                    NotificationEntry(
                        id: latest.id,
                        notification: latest,
                        displayTitle: senderName,
                        displayBody: actorNotifications.count == 1
                            ? latest.body
                            : "\(actorNotifications.count) messages from \(senderName)",
                        unreadCount: unreadCount,
                        groupedCount: actorNotifications.count,
                        groupedNotificationIDs: actorNotifications.map(\.id)
                    )
                )
                actorNotifications.forEach { consumedDirectMessageIDs.insert($0.id) }
            } else {
                entries.append(makeSingleEntry(from: notification))
            }
        }

        return entries
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    header
                    preferencesCard

                    if appState.notifications.isEmpty {
                        EmptyStateView(
                            title: "Nothing new yet",
                            message: "Comments, requests, return reminders, and messages will land here.",
                            systemImage: "bell"
                        )
                    } else {
                        ForEach(groupedNotifications, id: \.0) { title, notifications in
                            notificationSection(title: title, notifications: notifications)
                        }
                    }
                }
                .padding(AppTheme.pagePadding)
            }
        }
        .navigationTitle("Notifications")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        #endif
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Mark Read") {
                    appState.markAllNotificationsRead()
                }
                .font(AppTheme.bodyFont(size: 13, weight: .semibold))
                .foregroundStyle(appState.unreadNotificationCount == 0 ? AppTheme.softInk : AppTheme.accent)
                .disabled(appState.unreadNotificationCount == 0)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notification Center")
                .font(AppTheme.titleFont(size: 30))
                .foregroundStyle(AppTheme.ink)

            Text("A single spot for comments, DMs, borrow requests, return reminders, and new closet activity.")
                .font(AppTheme.bodyFont(size: 15))
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var preferencesCard: some View {
        let preferences = appState.notificationPreferences
            ?? appState.currentUser.map { ThreadNotificationPreferences(userID: $0.id) }

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionTitle("Preferences")
                Spacer()
                InfoChip(title: "Push next", systemImage: "paperplane.fill", tint: AppTheme.accent)
            }

            if let preferences {
                Toggle(isOn: preferenceBinding(\.friendNewItemAlertsEnabled, preferences: preferences)) {
                    Text("Friend new-item alerts")
                        .font(AppTheme.bodyFont(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.ink)
                }
                .tint(AppTheme.accent)

                Picker(
                    "Return reminders",
                    selection: preferenceBinding(\.returnReminderCadence, preferences: preferences)
                ) {
                    ForEach(ReturnReminderCadence.allCases) { cadence in
                        Text(cadence.displayName).tag(cadence)
                    }
                }
                .font(AppTheme.bodyFont(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.ink)
                .pickerStyle(.segmented)

                Text("These preferences control in-app and push delivery now.")
                    .font(AppTheme.bodyFont(size: 12))
                    .foregroundStyle(AppTheme.mutedInk)

                Divider()
                    .overlay(AppTheme.border)

                Toggle(isOn: preferenceBinding(\.pushNotificationsEnabled, preferences: preferences)) {
                    Text("Push notifications")
                        .font(AppTheme.bodyFont(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.ink)
                }
                .tint(AppTheme.accent)

                if preferences.pushNotificationsEnabled {
                    pushCategoryToggle("Borrow requests", keyPath: \.pushBorrowRequestsEnabled, preferences: preferences)
                    pushCategoryToggle("Comments", keyPath: \.pushCommentsEnabled, preferences: preferences)
                    pushCategoryToggle("Messages", keyPath: \.pushMessagesEnabled, preferences: preferences)
                    pushCategoryToggle("Friend new items", keyPath: \.pushFriendNewItemsEnabled, preferences: preferences)
                    pushCategoryToggle("Return reminders", keyPath: \.pushReturnRemindersEnabled, preferences: preferences)
                }

                Button {
                    Task {
                        await pushPermissionManager.requestAuthorizationAndRegister()
                    }
                } label: {
                    Label("Enable Device Push", systemImage: "bell.badge.fill")
                        .font(AppTheme.bodyFont(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.selectedPillText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(AppTheme.selectedPillBackground, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                }
                .buttonStyle(.plain)

                if let errorMessage = pushPermissionManager.errorMessage {
                    Text(errorMessage)
                        .font(AppTheme.bodyFont(size: 12))
                        .foregroundStyle(.red)
                }
            }
        }
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }

    private func pushCategoryToggle(
        _ title: String,
        keyPath: WritableKeyPath<ThreadNotificationPreferences, Bool>,
        preferences: ThreadNotificationPreferences
    ) -> some View {
        Toggle(isOn: preferenceBinding(keyPath, preferences: preferences)) {
            Text(title)
                .font(AppTheme.bodyFont(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.mutedInk)
        }
        .tint(AppTheme.accent)
    }

    private func notificationSection(title: String, notifications: [NotificationEntry]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppTheme.bodyFont(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.mutedInk)
                .textCase(.uppercase)

            VStack(spacing: 10) {
                ForEach(notifications) { entry in
                    notificationDestination(for: entry)
                }
            }
        }
    }

    @ViewBuilder
    private func notificationDestination(for entry: NotificationEntry) -> some View {
        let notification = entry.notification
        if
            let itemID = notification.itemID,
            let item = appState.threadItems.first(where: { $0.id == itemID })
        {
            NavigationLink {
                ThreadItemDetailView(item: item)
            } label: {
                NotificationRow(entry: entry)
            }
            .buttonStyle(.plain)
            .simultaneousGesture(TapGesture().onEnded {
                markEntryRead(entry)
            })
        } else {
            Button {
                appState.openNotification(notification)
                markEntryRead(entry)
            } label: {
                NotificationRow(entry: entry)
            }
            .buttonStyle(.plain)
        }
    }

    private func preferenceBinding<Value>(
        _ keyPath: WritableKeyPath<ThreadNotificationPreferences, Value>,
        preferences: ThreadNotificationPreferences
    ) -> Binding<Value> {
        Binding(
            get: {
                (appState.notificationPreferences ?? preferences)[keyPath: keyPath]
            },
            set: { newValue in
                var updated = appState.notificationPreferences ?? preferences
                updated[keyPath: keyPath] = newValue
                appState.saveNotificationPreferences(updated)
            }
        )
    }

    private func makeSingleEntry(from notification: ThreadNotification) -> NotificationEntry {
        NotificationEntry(
            id: notification.id,
            notification: notification,
            displayTitle: notification.title,
            displayBody: notification.body,
            unreadCount: notification.isRead ? 0 : 1,
            groupedCount: 1,
            groupedNotificationIDs: [notification.id]
        )
    }

    private func userDisplayName(for userID: UserProfile.ID) -> String {
        if appState.currentUser?.id == userID {
            return appState.currentUser?.displayName ?? "You"
        }
        return appState.users.first(where: { $0.id == userID })?.displayName ?? "New Message"
    }

    private func markEntryRead(_ entry: NotificationEntry) {
        entry.groupedNotificationIDs.forEach { appState.markNotificationRead($0) }
    }
}

private struct NotificationRow: View {
    let entry: NotificationEntry

    var body: some View {
        let notification = entry.notification

        HStack(alignment: .top, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: notification.kind.iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.accent)
                    .frame(width: 38, height: 38)
                    .background(AppTheme.accentSoft, in: Circle())

                if entry.unreadCount > 0 {
                    Circle()
                        .fill(AppTheme.clay)
                        .frame(width: 10, height: 10)
                        .overlay(Circle().stroke(AppTheme.surface, lineWidth: 2))
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(entry.displayTitle)
                        .font(AppTheme.bodyFont(size: 15, weight: .semibold))
                        .foregroundStyle(AppTheme.ink)

                    Spacer()

                    Text(notificationTimestamp(notification.createdAt))
                        .font(AppTheme.bodyFont(size: 11))
                        .foregroundStyle(AppTheme.softInk)
                }

                Text(entry.displayBody)
                    .font(AppTheme.bodyFont(size: 13))
                    .foregroundStyle(AppTheme.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    InfoChip(title: notification.kind.displayName, systemImage: nil, tint: AppTheme.accent)
                    if entry.isGroupedDirectMessage {
                        InfoChip(title: "\(entry.unreadCount) unread", systemImage: nil, tint: AppTheme.clay)
                    }
                }
            }
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(entry.unreadCount > 0 ? AppTheme.accent.opacity(0.45) : AppTheme.border, lineWidth: 1)
        )
    }

    private func notificationTimestamp(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return date.formatted(.relative(presentation: .numeric))
        }

        return date.formatted(date: .abbreviated, time: .shortened)
    }
}

struct NotificationCenterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NotificationCenterView()
                .environmentObject(AppState())
                .environmentObject(PushNotificationPermissionManager())
        }
    }
}
