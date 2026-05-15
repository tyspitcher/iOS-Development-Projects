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
    var follower_count: Int
    var following_count: Int
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

struct SupabaseFriendRequestRow: Codable {
    var id: UUID
    var requester_id: UUID
    var recipient_id: UUID
    var status: String
    var created_at: Date?
    var responded_at: Date?
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
