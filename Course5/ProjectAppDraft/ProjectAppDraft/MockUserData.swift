//
//  MockUserData.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 4/13/26.
//
import Foundation

// mock user data
let tyson = User(id: UUID(), firstName: "Tyson", lastName: "Pitcher", userName: "tyson.pitcher", bio: "I'm a software engineer", techInterests: "Swift, SwiftUI, and more!", profileImage: "tysonProfile", backgroundImage: "tysonBackground")

let steph = User(id: UUID(), firstName: "Steph", lastName: "Pitcher", userName: "kotta16", bio: "I'm not big on coding, but I'm big on my husband, and he likes to code.", techInterests: "I have a PC laptop.", profileImage: nil, backgroundImage: nil)


// mock post data
var userPosts: [Post] = [
    // recent post by Tyson
    Post(
        id: UUID(),
        authorID: tyson.id,
        date: Date(),
        content: "It's been fun working with SwiftUI. I think it's been my favorite part so far because that's what make it feel like I made something. It's really satisfying."
    ),
    // earlier post by Steph
    Post(
        id: UUID(),
        authorID: steph.id,
        date: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
        content: "Trying out this app Tyson is building. Not bad!"
    ),
    // another Tyson post from yesterday
    Post(
        id: UUID(),
        authorID: tyson.id,
        date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
        content: "Experimenting with different fonts. I think if you go too crazy it just makes your app look bad."
    ),
    // another Steph post from two days ago
    Post(
        id: UUID(),
        authorID: steph.id,
        date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
        content: "PC life chose me. But I do love my iPhone!"
    )
]

// mock comment data
var seedCommentsByPost: [UUID: [Comment]] = {
    guard userPosts.count >= 2 else { return [:] }

    return [
        userPosts[0].id: [
            Comment(id: UUID(), postID: userPosts[0].id, authorID: steph.id,
                    date: Date().addingTimeInterval(-1800),
                    content: "So fun to see what you've been working on!"),
            Comment(id: UUID(), postID: userPosts[0].id, authorID: tyson.id,
                    date: Date().addingTimeInterval(-900),
                    content: "Thanks you!")
        ],
        userPosts[1].id: [
            Comment(id: UUID(), postID: userPosts[1].id, authorID: tyson.id,
                    date: Date().addingTimeInterval(-7200),
                    content: "Love this take. Keep posting updates.")
        ]
    ]
}()
