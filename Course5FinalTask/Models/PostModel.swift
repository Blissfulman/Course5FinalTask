//
//  PostModel.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 30.11.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

struct PostModel: Decodable, Identifiable {
    
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
    
    // MARK: - Initialization
    
    init?(postCoreData: PostCoreData?) {
        guard let postCoreData = postCoreData,
              let id = postCoreData.id,
              let description = postCoreData.desc,
              let createdTime = postCoreData.createdTime,
              let author = postCoreData.author,
              let authorUsername = postCoreData.authorUsername else { return nil }
        
        self.id = id
        self.description = description
        self.image = nil
        self.createdTime = createdTime
        self.currentUserLikesThisPost = postCoreData.currentUserLikesThisPost
        self.likedByCount = Int(postCoreData.likedByCount)
        self.author = author
        self.authorUsername = authorUsername
        self.authorAvatar = nil
        self.imageData = postCoreData.imageData
        self.authorAvatarData = postCoreData.authorAvatarData
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
    let postID: PostModel.ID
}

struct NewPostRequestModel: Encodable {
    let image: String
    let description: String
}
