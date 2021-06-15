//
//  UserListType.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 09.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

enum UserListType {
    case likes
    case followers
    case followings
    
    var title: String {
        switch self {
        case .likes:
            return "Likes".localized()
        case .followers:
            return "Followers".localized()
        case .followings:
            return "Followings".localized()
        }
    }
}
