//
//  FirebaseThreadRepository.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import Foundation

enum FirebaseThreadRepositoryError: Error {
    case notImplemented
}

final class FirebaseThreadRepository: ThreadRepository {
    // TODO: Inject Firebase Auth and Firestore dependencies after adding Firebase SDK.
    // Example future shape:
    // private let auth: Auth
    // private let db: Firestore
    //
    // The Firebase Auth user ID should be the canonical current-user identifier
    // for reads/writes scoped to the signed-in user:
    // let firebaseUserID = Auth.auth().currentUser?.uid
    //
    // Expected Firestore collections:
    // - FirestoreCollections.users
    // - FirestoreCollections.threadItems
    // - FirestoreCollections.borrowRequests
    // - FirestoreCollections.dmThreads

    init() {
        // TODO: Accept configured Firebase services here once Firebase is installed.
    }

    func fetchCurrentUser() async throws -> UserProfile {
        // TODO: Read users/{firebaseAuthUserID}.
        // Firebase Auth UID maps to the document ID in FirestoreCollections.users.
        throw FirebaseThreadRepositoryError.notImplemented
    }

    func fetchUsers() async throws -> [UserProfile] {
        // TODO: Query FirestoreCollections.users for public/friend-visible profiles.
        throw FirebaseThreadRepositoryError.notImplemented
    }

    func fetchThreadItems() async throws -> [ThreadItem] {
        // TODO: Query FirestoreCollections.threadItems, filtered by viewer permissions.
        throw FirebaseThreadRepositoryError.notImplemented
    }

    func fetchBorrowRequests() async throws -> [BorrowRequest] {
        // TODO: Query FirestoreCollections.borrowRequests where requesterID or ownerID
        // matches the Firebase Auth user ID.
        throw FirebaseThreadRepositoryError.notImplemented
    }

    func fetchMessages() async throws -> [DMMessage] {
        // TODO: Query FirestoreCollections.dmThreads/{threadID}/messages for threads
        // involving the Firebase Auth user ID.
        throw FirebaseThreadRepositoryError.notImplemented
    }

    func fetchFriendRequestState() async throws -> FriendRequestState {
        // TODO: Query pending friend requests where requesterID or recipientID
        // matches the Firebase Auth user ID.
        throw FirebaseThreadRepositoryError.notImplemented
    }

    func saveUser(_ user: UserProfile) async throws {
        // TODO: Upsert users/{firebaseAuthUserID} for the signed-in user's profile.
        throw FirebaseThreadRepositoryError.notImplemented
    }

    func saveThreadItem(_ item: ThreadItem) async throws {
        // TODO: Upsert threadItems/{item.id}; ownerID should match Firebase Auth UID
        // for newly created closet items.
        throw FirebaseThreadRepositoryError.notImplemented
    }

    func saveBorrowRequest(_ request: BorrowRequest) async throws {
        // TODO: Upsert borrowRequests/{request.id}; requesterID should come from
        // Firebase Auth UID when creating a new request.
        throw FirebaseThreadRepositoryError.notImplemented
    }

    func saveMessage(_ message: DMMessage) async throws {
        // TODO: Write message into dmThreads/{threadID}/messages and set senderID
        // from Firebase Auth UID.
        throw FirebaseThreadRepositoryError.notImplemented
    }

    func saveFriendRequestState(_ state: FriendRequestState) async throws {
        // TODO: Persist friend request documents for the signed-in Firebase Auth UID.
        throw FirebaseThreadRepositoryError.notImplemented
    }

    func deleteThreadItem(_ itemID: ThreadItem.ID) async throws {
        // TODO: Delete threadItems/{itemID}; only allow when ownerID matches the
        // signed-in Firebase Auth UID. Related borrow requests should be archived
        // or deleted based on product policy.
        throw FirebaseThreadRepositoryError.notImplemented
    }
}
