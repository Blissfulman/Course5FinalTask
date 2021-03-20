//
//  DataStorageService.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 19.03.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Protocols

protocol DataStorageServiceProtocol {
    func saveUser(_ userModel: UserModel)
    func savePost(_ postModel: PostModel)
    func savePosts(_ postModels: [PostModel])
    func getPosts() -> [PostModel]
    func saveData()
    func removeAllPosts()
}

final class DataStorageService: DataStorageServiceProtocol {
    
    // MARK: - Static properties
    
    static let shared = DataStorageService()
    
    // MARK: - Properties
    
    private let coreDataService = CoreDataService(modelName: "Course5FinalTask")
    private let context: NSManagedObjectContext
    
    // MARK: - Initializers
    
    private init() {
        context = coreDataService.getContext()
    }
    
    // MARK: - Public methods
    
    func saveUser(_ userModel: UserModel) {
        let user = coreDataService.createObject(from: UserCoreData.self)
        
        user.id = userModel.id
        user.username = userModel.username
        user.fullName = userModel.fullName
        user.currentUserFollowsThisUser = userModel.currentUserFollowsThisUser
        user.currentUserIsFollowedByThisUser = userModel.currentUserIsFollowedByThisUser
        user.followsCount = Int16(userModel.followsCount)
        user.followedByCount = Int16(userModel.followedByCount)
        user.avatarData = userModel.avatar?.fetchPNGImageData()
        
        coreDataService.save(context: context)
    }
    
    func savePost(_ postModel: PostModel) {
        let post = coreDataService.createObject(from: PostCoreData.self)
        
        post.id = postModel.id
        post.desc = postModel.description
        post.createdTime = postModel.createdTime
        post.currentUserLikesThisPost = postModel.currentUserLikesThisPost
        post.likedByCount = Int16(postModel.likedByCount)
        post.author = postModel.author
        post.authorUsername = postModel.authorUsername
        post.imageData = postModel.image?.fetchPNGImageData()
        post.authorAvatarData = postModel.authorAvatar?.fetchPNGImageData()
        
        coreDataService.save(context: context)
    }
    
    func savePosts(_ postModels: [PostModel]) {
        postModels.forEach {
            let post = coreDataService.createObject(from: PostCoreData.self)
            post.id = $0.id
            post.desc = $0.description
            post.createdTime = $0.createdTime
            post.currentUserLikesThisPost = $0.currentUserLikesThisPost
            post.likedByCount = Int16($0.likedByCount)
            post.author = $0.author
            post.authorUsername = $0.authorUsername
            post.imageData = $0.image?.fetchPNGImageData()
            post.authorAvatarData = $0.authorAvatar?.fetchPNGImageData()
        }
        coreDataService.save(context: context)
    }
    
    func getPosts() -> [PostModel] {
        let posts = coreDataService.fetchData(for: PostCoreData.self)
        print(posts.count)
        return posts.compactMap { PostModel(postCoreData: $0) }
    }
    
    func saveData() {
        coreDataService.save(context: context)
    }
    
    func removeAllPosts() {
        let posts = coreDataService.fetchData(for: PostCoreData.self)
        posts.forEach { coreDataService.delete(object: $0) }
    }
}
