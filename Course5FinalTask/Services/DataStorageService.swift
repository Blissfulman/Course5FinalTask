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
    func saveData()
    func saveUser(_ userModel: UserModel)
    func savePost(_ postModel: PostModel)
    func savePosts(_ postModels: [PostModel])
    func getCurrentUser() -> UserModel?
    func getAllPosts() -> [PostModel]
    func getPostsOfUser(withID userID: String) -> [PostModel]
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
    
    func saveData() {
        coreDataService.save(context: context)
    }
    
    func saveUser(_ userModel: UserModel) {
        let user = coreDataService.createObject(from: UserCoreData.self)
        fillUserCoreData(user, from: userModel)
        coreDataService.save(context: context)
    }
    
    func savePost(_ postModel: PostModel) {
        let post = coreDataService.createObject(from: PostCoreData.self)
        fillPostCoreData(post, from: postModel)
        coreDataService.save(context: context)
    }
    
    func savePosts(_ postModels: [PostModel]) {
        removeAllPosts()
        postModels.forEach {
            let post = coreDataService.createObject(from: PostCoreData.self)
            fillPostCoreData(post, from: $0)
        }
        coreDataService.save(context: context)
    }
    
    func getCurrentUser() -> UserModel? {
        let users = coreDataService.fetchData(for: UserCoreData.self)
        print("users.count: ", users.count) // TEMP
        guard let userCoreData = users.first else { return nil }
        return UserModel(userCoreData: userCoreData)
    }
    
    func getAllPosts() -> [PostModel] {
        let posts = coreDataService.fetchData(for: PostCoreData.self)
        print(posts.count) // TEMP
        return posts.compactMap { PostModel(postCoreData: $0) }
    }
    
    func getPostsOfUser(withID userID: String) -> [PostModel] {
        getAllPosts()
    }
    
    func removeAllPosts() {
        let posts = coreDataService.fetchData(for: PostCoreData.self)
        posts.forEach { coreDataService.delete(object: $0) }
    }
    
    // MARK: - Private methods
    
    private func fillUserCoreData(_ userCoreData: UserCoreData, from userModel: UserModel) {
        userCoreData.id = userModel.id
        userCoreData.username = userModel.username
        userCoreData.fullName = userModel.fullName
        userCoreData.currentUserFollowsThisUser = userModel.currentUserFollowsThisUser
        userCoreData.currentUserIsFollowedByThisUser = userModel.currentUserIsFollowedByThisUser
        userCoreData.followsCount = Int16(userModel.followsCount)
        userCoreData.followedByCount = Int16(userModel.followedByCount)
        userCoreData.avatarData = userModel.getAvatarData()
    }
    
    private func fillPostCoreData(_ postCoreData: PostCoreData, from postModel: PostModel) {
        postCoreData.id = postModel.id
        postCoreData.desc = postModel.description
        postCoreData.createdTime = postModel.createdTime
        postCoreData.currentUserLikesThisPost = postModel.currentUserLikesThisPost
        postCoreData.likedByCount = Int16(postModel.likedByCount)
        postCoreData.author = postModel.author
        postCoreData.authorUsername = postModel.authorUsername
        postCoreData.imageData = postModel.getImageData()
        postCoreData.authorAvatarData = postModel.getAuthorAvatarData()
    }
}
