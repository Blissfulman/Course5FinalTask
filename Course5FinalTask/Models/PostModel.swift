//
//  PostModel.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 30.11.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

struct PostModel: Decodable {
    
    // MARK: - Properties
    
    let id: String
    let description: String
    let image: URL?
    let createdTime: Date
    let currentUserLikesThisPost: Bool
    let likedByCount: Int
    let author: String
    let authorUsername: String
    let authorAvatar: URL?
    let imageData: Data?
    let authorAvatarData: Data?
    
    // MARK: - Initializers
    
    init?(coreDataPost: PostCoreData) {
        guard let id = coreDataPost.id,
              let description = coreDataPost.desc,
              let createdTime = coreDataPost.createdTime,
              let author = coreDataPost.author,
              let authorUsername = coreDataPost.authorUsername else { return nil }
        
        self.id = id
        self.description = description
        self.image = nil
        self.createdTime = createdTime
        self.currentUserLikesThisPost = coreDataPost.currentUserLikesThisPost
        self.likedByCount = Int(coreDataPost.likedByCount)
        self.author = author
        self.authorUsername = authorUsername
        self.authorAvatar = nil
        self.imageData = coreDataPost.imageData
        self.authorAvatarData = coreDataPost.authorAvatarData
    }
    
    // MARK: - Public methods
    
    func getImageData() -> Data {
        NetworkService.isOnline
            ? image.fetchPNGImageData()
            : imageData ?? Data()
    }
    
    func getAuthorAvatarData() -> Data {
        NetworkService.isOnline
            ? authorAvatar.fetchPNGImageData()
            : authorAvatarData ?? Data()
    }
}

struct PostIDRequestModel: Encodable {
    let postID: String
}

struct NewPostRequestModel: Encodable {
    let image: String
    let description: String
}
