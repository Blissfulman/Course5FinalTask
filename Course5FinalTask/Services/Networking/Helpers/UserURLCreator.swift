//
//  UserURLCreator.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 11.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

enum UserURLCreator {
    case getUser(userID: UserModel.ID)
    case currentUser
    case follow
    case unfollow
    case followers(userID: UserModel.ID)
    case followings(userID: UserModel.ID)

    var url: URL? {
        let baseURL = ServerConstant.baseURL

        switch self {
        case .getUser(let userID):
            return URL(string: baseURL + "users/\(userID)")
        case .currentUser:
            return URL(string: baseURL + "users/me")
        case .follow:
            return URL(string: baseURL + "users/follow")
        case .unfollow:
            return URL(string: baseURL + "users/unfollow")
        case .followers(let userID):
            return URL(string: baseURL + "users/\(userID)/followers")
        case .followings(let userID):
            return URL(string: baseURL + "users/\(userID)/following")
        }
    }
}
