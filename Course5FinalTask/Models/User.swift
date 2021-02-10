//
//  User.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 29.11.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

struct User: Decodable {
    let id: String
    let username: String
    let fullName: String
    let avatar: URL
    let currentUserFollowsThisUser: Bool
    let currentUserIsFollowedByThisUser: Bool
    let followsCount: Int
    let followedByCount: Int
}

struct UserIDRequest: Encodable {
    let userID: String
}
