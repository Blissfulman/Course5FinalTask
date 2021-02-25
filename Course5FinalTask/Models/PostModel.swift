//
//  PostModel.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 30.11.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

struct PostModel: Decodable {
    let id: String
    let description: String
    let image: URL
    let createdTime: Date
    let currentUserLikesThisPost: Bool
    let likedByCount: Int
    let author: String
    let authorUsername: String
    let authorAvatar: URL
}

struct PostIDRequestModel: Encodable {
    let postID: String
}

struct NewPostRequestModel: Encodable {
    let image: String
    let description: String
}
