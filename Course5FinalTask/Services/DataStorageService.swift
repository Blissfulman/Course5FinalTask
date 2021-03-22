//
//  DataStorageService.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 19.03.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import CoreData

// MARK: - Protocols

protocol DataStorageServiceProtocol {
    func saveData()
    func saveCurrentUserID(_ id: String)
    func saveUser(_ userModel: UserModel)
    func savePost(_ postModel: PostModel)
    func savePosts(_ postModels: [PostModel])
    func savePosts(_ postModels: [PostModel], forUserID userID: String)
    func getCurrentUser() -> UserModel?
    func getUser(withID userID: String) -> UserModel?
    func getAllPosts() -> [PostModel]
    func getPostsOfUser(withID userID: String) -> [PostModel]
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
    
    func saveCurrentUserID(_ id: String) {
        let currentUser = coreDataService.createObject(from: CurrentUser.self)
        currentUser.id = id
        saveData()
    }
    
    func saveUser(_ userModel: UserModel) {
        let user = coreDataService.createObject(from: UserCoreData.self)
        fillUserCoreData(user, from: userModel)
        saveData()
    }
    
    func savePost(_ postModel: PostModel) {
        let post = coreDataService.createObject(from: PostCoreData.self)
        fillPostCoreData(post, from: postModel)
        saveData()
    }
    
    func savePosts(_ postModels: [PostModel]) {
        removeAllPosts()
        postModels.forEach {
            let post = coreDataService.createObject(from: PostCoreData.self)
            fillPostCoreData(post, from: $0)
        }
        saveData()
    }
    
    func savePosts(_ postModels: [PostModel], forUserID userID: String) {
        postModels.forEach {
            let post = coreDataService.createObject(from: PostCoreData.self)
            fillPostCoreData(post, from: $0, forAuthorID: userID)
        }
        saveData()
    }
    
    func getCurrentUser() -> UserModel? {
        guard let currentUserID = getCurrentUserID(),
              let currentUser = getUser(withID: currentUserID) else { return nil }
        return currentUser
    }
    
    func getUser(withID userID: String) -> UserModel? {
        let users = coreDataService.fetchData(for: UserCoreData.self,
                                              predicate: makeUserPredicate(userID: userID))
        print("Users with ID \(userID) count: ", users.count) // TEMP
        return UserModel(userCoreData: users.first)
    }
    
    func getAllPosts() -> [PostModel] {
        let posts = coreDataService.fetchData(for: PostCoreData.self)
        print(posts.count) // TEMP
        return posts.compactMap { PostModel(postCoreData: $0) }
    }
    
    func getPostsOfUser(withID userID: String) -> [PostModel] {
        let posts = coreDataService.fetchData(for: PostCoreData.self,
                                              predicate: makePostPredicate(authorID: userID))
        print("PostsOfUser count: ", posts.count) // TEMP
        return posts.compactMap { PostModel(postCoreData: $0) }
    }
    
    // MARK: - Private methods
    
    private func getCurrentUserID() -> String? {
        let currentUsers = coreDataService.fetchData(for: CurrentUser.self)
        print("Current users in storage:", currentUsers.count) // TEMP
        return currentUsers.first?.id ?? nil
    }
    
    private func removeAllPosts() {
        let posts = coreDataService.fetchData(for: PostCoreData.self)
        posts.forEach { coreDataService.delete(object: $0) }
    }
    
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
    
    private func fillPostCoreData(_ postCoreData: PostCoreData,
                                  from postModel: PostModel,
                                  forAuthorID authorID: String? = nil) {
        postCoreData.id = postModel.id
        postCoreData.desc = postModel.description
        postCoreData.createdTime = postModel.createdTime
        postCoreData.currentUserLikesThisPost = postModel.currentUserLikesThisPost
        postCoreData.likedByCount = Int16(postModel.likedByCount)
        postCoreData.author = postModel.author
        postCoreData.authorUsername = postModel.authorUsername
        postCoreData.imageData = postModel.getImageData()
        postCoreData.authorAvatarData = postModel.getAuthorAvatarData()
        postCoreData.authorID = authorID
    }
    
    private func makeUserPredicate(userID: String) -> NSCompoundPredicate {
        var predicates = [NSPredicate]()
        let idPredicate = NSPredicate(format: "id == '\(userID)'")
        predicates.append(idPredicate)
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    private func makePostPredicate(authorID: String) -> NSCompoundPredicate {
        var predicates = [NSPredicate]()
        let idPredicate = NSPredicate(format: "authorID == '\(authorID)'")
        predicates.append(idPredicate)
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}
