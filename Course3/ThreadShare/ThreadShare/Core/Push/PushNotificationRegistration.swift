//
//  PushNotificationRegistration.swift
//  ThreadShare
//
//  Created by Codex on 5/27/26.
//

import Foundation
import Combine

#if canImport(UIKit)
import UIKit
import UserNotifications
#endif

extension Notification.Name {
    static let threadShareRemoteDeviceTokenDidRegister = Notification.Name("threadShareRemoteDeviceTokenDidRegister")
    static let threadSharePushNotificationDidOpen = Notification.Name("threadSharePushNotificationDidOpen")
}

enum PushDeviceTokenStore {
    static var currentToken: String?

    static func tokenString(from data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }
}

enum PushNotificationRouteStore {
    static var pendingNotificationID: UUID?

    static func notificationID(from userInfo: [AnyHashable: Any]) -> UUID? {
        guard let rawValue = userInfo["notification_id"] as? String else { return nil }
        return UUID(uuidString: rawValue)
    }
}

#if canImport(UIKit)
final class ThreadShareAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Allow banners/sounds while the app is active (foreground).
        UNUserNotificationCenter.current().delegate = self

        if
            let remoteUserInfo = launchOptions?[.remoteNotification] as? [AnyHashable: Any],
            let notificationID = PushNotificationRouteStore.notificationID(from: remoteUserInfo)
        {
            PushNotificationRouteStore.pendingNotificationID = notificationID
        }
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = PushDeviceTokenStore.tokenString(from: deviceToken)
        PushDeviceTokenStore.currentToken = token
        NotificationCenter.default.post(
            name: .threadShareRemoteDeviceTokenDidRegister,
            object: token
        )
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        PushDeviceTokenStore.currentToken = nil
    }
}

extension ThreadShareAppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound, .badge]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard
            let notificationID = PushNotificationRouteStore.notificationID(
                from: response.notification.request.content.userInfo
            )
        else {
            return
        }

        PushNotificationRouteStore.pendingNotificationID = notificationID
        NotificationCenter.default.post(
            name: .threadSharePushNotificationDidOpen,
            object: notificationID
        )
    }
}

@MainActor
final class PushNotificationPermissionManager: ObservableObject {
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published private(set) var errorMessage: String?

    func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    func requestAuthorizationAndRegister() async {
        errorMessage = nil

        do {
            let center = UNUserNotificationCenter.current()
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            await refreshAuthorizationStatus()

            if granted {
                UIApplication.shared.registerForRemoteNotifications()
            }
        } catch {
            errorMessage = "ThreadShare could not request push notification permission."
        }
    }
}
#endif
