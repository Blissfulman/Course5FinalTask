//
//  UserModel.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 29.11.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

struct UserModel: Decodable, Identifiable {
    
    // MARK: - Properties
    
    let id: String
    let username: String
    let fullName: String
    let avatar: URL?
    let currentUserFollowsThisUser: Bool
    let currentUserIsFollowedByThisUser: Bool
    let followsCount: Int
    let followedByCount: Int
    let avatarData: Data?
    
    // MARK: - Initializers
    
    init?(userCoreData: UserCoreData?) {
        guard let userCoreData = userCoreData,
              let id = userCoreData.id,
              let username = userCoreData.username,
              let fullName = userCoreData.fullName else { return nil }
        
        self.id = id
        self.username = username
        self.fullName = fullName
        self.avatar = nil
        self.currentUserFollowsThisUser = userCoreData.currentUserFollowsThisUser
        self.currentUserIsFollowedByThisUser = userCoreData.currentUserIsFollowedByThisUser
        self.followsCount = Int(userCoreData.followsCount)
        self.followedByCount = Int(userCoreData.followedByCount)
        self.avatarData = userCoreData.avatarData
    }
    
    // MARK: - Public methods
        
    func getAvatarData() -> Data {
        NetworkService.isOnline
            ? avatar.fetchPNGImageData()
            : avatarData ?? Data()
    }
}

struct UserIDRequestModel: Encodable {
    let userID: UserModel.ID
}
