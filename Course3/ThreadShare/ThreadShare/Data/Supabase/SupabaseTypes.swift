//
//  SupabaseTypes.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import Foundation

extension JSONEncoder {
    static var threadShareSupabase: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

extension JSONDecoder {
    static var threadShareSupabase: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

struct SupabaseSession: Codable, Equatable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date?
    let userID: UUID
    let email: String
}

struct SupabaseAuthUser: Codable {
    let id: UUID
    let email: String?
}

struct SupabaseAuthSessionResponse: Codable {
    let access_token: String
    let refresh_token: String
    let expires_in: Int?
    let user: SupabaseAuthUser
}

struct SupabaseProfileRow: Codable {
    var id: UUID
    var email: String
    var display_name: String
    var username: String
    var bio: String
    var avatar_bucket: String
    var avatar_path: String?
    var city: String
    var visibility: String
    var style_interests: [String]
    var favorite_brands: [String]
    var color_palette_preference_ids: [String]
    var requires_follower_approval: Bool
    var follower_count: Int
    var following_count: Int
    var last_login_at: Date? = nil
    var last_active_at: Date? = nil
    var created_at: Date?
    var updated_at: Date?
}

struct SupabaseThreadItemRow: Codable {
    var id: UUID
    var owner_id: UUID
    var title: String
    var brand: String
    var size: String
    var color_name: String
    var category: String
    var occasions: [String]
    var condition: String
    var availability_status: String
    var image_bucket: String
    var image_path: String?
    var photo_aspect_ratio: Double
    var notes: String
    var fits_like: String
    var where_purchased: String
    var purchase_link: String?
    var likes_count: Int
    var created_at: Date?
    var updated_at: Date?
}

struct SupabaseThreadItemImagePathRow: Codable {
    var image_path: String?
}

struct SupabaseLikeRow: Codable {
    var id: UUID
    var user_id: UUID
    var item_id: UUID
    var liked_at: Date
}

struct SupabaseBorrowRequestRow: Codable {
    var id: UUID
    var item_id: UUID
    var requester_id: UUID
    var owner_id: UUID
    var status: String
    var requested_start_date: String
    var requested_end_date: String
    var message: String
    var borrower_marked_returned_at: Date?
    var created_at: Date?
    var updated_at: Date?
}

struct SupabaseMessageRow: Codable {
    var id: UUID
    var sender_id: UUID
    var recipient_id: UUID
    var related_borrow_request_id: UUID?
    var body: String
    var sent_at: Date
    var is_read: Bool
}

struct SupabaseFollowRow: Codable {
    var id: UUID
    var follower_id: UUID
    var followed_user_id: UUID
    var created_at: Date?
}

struct SupabaseFollowRequestRow: Codable {
    var id: UUID
    var requester_id: UUID
    var recipient_id: UUID
    var created_at: Date?
}

struct SupabaseFriendRequestRow: Codable {
    var id: UUID
    var requester_id: UUID
    var recipient_id: UUID
    var status: String
    var created_at: Date?
    var responded_at: Date?
}

struct SupabaseUserBlockRow: Codable {
    var id: UUID
    var blocker_id: UUID
    var blocked_user_id: UUID
    var created_at: Date?
}

struct SupabaseItemCommentRow: Codable {
    var id: UUID
    var item_id: UUID
    var author_id: UUID
    var body: String
    var created_at: Date?
}

struct SupabaseAccountDeletionRequestRow: Codable {
    var id: UUID
    var user_id: UUID
    var requested_at: Date
    var scheduled_deletion_at: Date
    var canceled_at: Date?
    var completed_at: Date?
    var status: String
    var created_at: Date?
    var updated_at: Date?
}

struct SupabaseItemReportRow: Codable {
    var id: UUID
    var reporter_id: UUID
    var item_id: UUID
    var owner_id: UUID
    var reason: String
    var details: String
    var status: String
    var created_at: Date?
}

struct SupabaseNotificationRow: Codable {
    var id: UUID
    var recipient_id: UUID
    var actor_id: UUID?
    var kind: String
    var title: String
    var body: String
    var item_id: UUID?
    var borrow_request_id: UUID?
    var message_id: UUID?
    var created_at: Date?
    var read_at: Date?
}

struct SupabaseNotificationPreferencesRow: Codable {
    var user_id: UUID
    var friend_new_item_alerts_enabled: Bool
    var return_reminder_cadence: String
    var push_notifications_enabled: Bool
    var push_borrow_requests_enabled: Bool
    var push_comments_enabled: Bool
    var push_messages_enabled: Bool
    var push_friend_new_items_enabled: Bool
    var push_return_reminders_enabled: Bool
    var created_at: Date?
    var updated_at: Date?
}

struct SupabasePushDeviceTokenRow: Codable {
    var id: UUID
    var user_id: UUID
    var platform: String
    var token: String
    var enabled: Bool
    var created_at: Date?
    var updated_at: Date?
    var last_registered_at: Date?
}

struct SupabaseReturnReminderRow: Codable {
    var id: UUID
    var user_id: UUID
    var borrow_request_id: UUID
    var cadence: String
    var next_reminder_at: Date
    var last_sent_at: Date?
    var is_enabled: Bool
    var created_at: Date?
    var updated_at: Date?
}

enum SupabaseDateCodec {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func dateString(from date: Date) -> String {
        dateFormatter.string(from: date)
    }

    static func date(from string: String) -> Date {
        dateFormatter.date(from: string) ?? Date()
    }
}
