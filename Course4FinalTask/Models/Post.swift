//
//  Post.swift
//  Course4FinalTask
//
//  Created by User on 30.11.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

struct Post: Codable {
    let id: String
    var description: String
    var image: URL
    var createdTime: Date
    var currentUserLikesThisPost: Bool
    var likedByCount: Int
    var author: String
    var authorUsername: String
    var authorAvatar: URL
    
    private enum CodingKeys: CodingKey {
        case id
        case description
        case image
        case createdTime
        case currentUserLikesThisPost
        case likedByCount
        case author
        case authorUsername
        case authorAvatar
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        description = try values.decode(String.self, forKey: .description)
        let imageString = try values.decode(String.self, forKey: .image)
        image = URL(string: imageString)!
        let createdTimeString = try values.decode(String.self, forKey: .createdTime)
        createdTime = DateFormatter.postDateFormatter.date(from: createdTimeString)!
        currentUserLikesThisPost = try values.decode(Bool.self, forKey: .currentUserLikesThisPost)
        likedByCount = try values.decode(Int.self, forKey: .likedByCount)
        author = try values.decode(String.self, forKey: .author)
        authorUsername = try values.decode(String.self, forKey: .authorUsername)
        let authorAvatarString = try values.decode(String.self, forKey: .authorAvatar)
        authorAvatar = URL(string: authorAvatarString)!
    }
}

struct PostIDRequest: Encodable {
    let postID: String
}
