//
//  PostURLCreator.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 11.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

enum PostURLCreator {
    case feed
    case userPosts(userID: UserModel.ID)
    case post(postID: PostModel.ID)
    case like
    case unlike
    case usersLikedPost(postID: PostModel.ID)
    case create
    
    var url: URL? {
        let baseURL = ServerConstants.baseURL

        switch self {
        case .feed:
            return URL(string: baseURL + "posts/feed")
        case .userPosts(let userID):
            return URL(string: baseURL + "users/\(userID)/posts/")
        case .post(let postID):
            return URL(string: baseURL + "posts/\(postID)")
        case .like:
            return URL(string: baseURL + "posts/like")
        case .unlike:
            return URL(string: baseURL + "posts/unlike")
        case .usersLikedPost(let postID):
            return URL(string: baseURL + "posts/\(postID)/likes")
        case .create:
            return URL(string: baseURL + "posts/create")
        }
    }
}
