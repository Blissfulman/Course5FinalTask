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
    func savePosts(_ postModels: [PostModel], fromFeed: Bool, forUserID userID: String?)
    func getCurrentUser() -> UserModel?
    func getUser(withID userID: String) -> UserModel?
    func getFeedPosts() -> [PostModel]
    func getPostsOfUser(withID userID: String) -> [PostModel]
    func deleteAllData()
}

final class DataStorageService: DataStorageServiceProtocol {
    
    // MARK: - Static properties
    
    static let shared = DataStorageService()
    
    // MARK: - Properties
    
    private let coreDataService = CoreDataService(modelName: "Course5FinalTask")
    private let context: NSManagedObjectContext
    
    // MARK: - Initializers
    
    private init() {
        context = coreDataService.context
    }
    
    // MARK: - Public methods
    
    func saveData() {
        coreDataService.save(context: context)
    }
    
    func saveCurrentUserID(_ id: String) {
        // Сохранение ID текущего пользователя в базе только в случае его отсутствия в хранилище
        if coreDataService.fetchData(for: CurrentUser.self).isEmpty {
            let currentUser = coreDataService.createObject(from: CurrentUser.self)
            currentUser.id = id
            saveData()
        }
    }
    
    func saveUser(_ userModel: UserModel) {
        // Проверка есть ли уже такой пользователь в хранилище
        let users = coreDataService.fetchData(for: UserCoreData.self,
                                              predicate: makeUserIDPredicate(userID: userModel.id))
        if users.isEmpty {
            // Если такого пользователя нет в хранилище, то он создаётся
            let newUserCoreData = coreDataService.createObject(from: UserCoreData.self)
            fillUserCoreData(newUserCoreData, from: userModel)
        } else {
            // Если пользователь уже был сохранён, то его данные обновляются
            users.forEach { fillUserCoreData($0, from: userModel) }
        }
        saveData()
    }
    
    func savePosts(_ postModels: [PostModel], fromFeed: Bool, forUserID userID: String?) {
        // Получение всех сохраненных постов
        let postsCoreData = coreDataService.fetchData(for: PostCoreData.self)
        
        postModels.forEach { postModel in
            if let postCoreData = postsCoreData.first(where: { $0.id == postModel.id }) {
                // Если пост уже был сохранён в хранилище, то его данные обновляются
                fillPostCoreData(postCoreData, from: postModel, forAuthorID: userID)
            } else {
                // Если такого поста нет в хранилище, то он создаётся
                let newPostCoreData = coreDataService.createObject(from: PostCoreData.self)
                fillPostCoreData(newPostCoreData, from: postModel, forAuthorID: userID)
            }
        }
        
        if fromFeed {
            saveFeedPostIDs(postModels)
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
                                              predicate: makeUserIDPredicate(userID: userID))
        let totalUsers = coreDataService.fetchData(for: UserCoreData.self) // TEMP
        print("Total users in storage:", totalUsers.count) // TEMP
        return UserModel(userCoreData: users.first)
    }
    
    func getFeedPosts() -> [PostModel] {
        // Получение массива идентификаторов постов ленты
        let feedPostIDs = getFeedPostIDs()
        // Получение постов ленты из хранилища по их ID
        let feedPosts = feedPostIDs.compactMap {
            coreDataService.fetchData(for: PostCoreData.self,
                                      predicate: makePostIDPredicate(postID: $0)).first
        }
        print("Total feed posts:", feedPosts.count) // TEMP
        return feedPosts.compactMap { PostModel(postCoreData: $0) }
    }
    
    func getPostsOfUser(withID userID: String) -> [PostModel] {
        let posts = coreDataService.fetchData(for: PostCoreData.self,
                                              predicate: makeAuthorPostIDPredicate(authorID: userID))
        print("PostsOfUser count:", posts.count) // TEMP
        return posts.compactMap { PostModel(postCoreData: $0) }
    }
    
    func deleteAllData() {
        DispatchQueue.main.async {
            self.deleteAllUsers()
            self.deleteAllCurrentUsers()
            self.deleteAllPosts()
            self.deleteFeedPostIDs()
        }
    }
    
    // MARK: - Private methods
    
    private func saveFeedPostIDs(_ postModels: [PostModel]) {
        deleteFeedPostIDs()
        let feedPostIDs = postModels.map { $0.id }
        let feed = coreDataService.createObject(from: Feed.self)
        feed.postIDs = feedPostIDs.description.data(using: .utf16)
    }
    
    private func getFeedPostIDs() -> [String] {
        guard let feedPostIDsData = coreDataService.fetchData(for: Feed.self).first?.postIDs,
              let feedPostIDs = try? JSONDecoder().decode([String].self,
                                                          from: feedPostIDsData) else { return [] }
        print("FeedPostIDs:", feedPostIDs) // TEMP
        return feedPostIDs
    }
    
    private func getCurrentUserID() -> String? {
        let currentUsers = coreDataService.fetchData(for: CurrentUser.self)
        print("Current users in storage:", currentUsers.count) // TEMP
        return currentUsers.first?.id ?? nil
    }
    
    private func deleteAllUsers() {
        let users = coreDataService.fetchData(for: UserCoreData.self)
        users.forEach { coreDataService.delete(object: $0) }
    }
    
    private func deleteAllCurrentUsers() {
        let currentUsers = coreDataService.fetchData(for: CurrentUser.self)
        currentUsers.forEach { coreDataService.delete(object: $0) }
    }
    
    private func deleteAllPosts() {
        let posts = coreDataService.fetchData(for: PostCoreData.self)
        posts.forEach { coreDataService.delete(object: $0) }
    }
    
    private func deleteFeedPostIDs() {
        let feed = coreDataService.fetchData(for: Feed.self)
        feed.forEach { coreDataService.delete(object: $0) }
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
        // Чтобы уже сохранённый ID автора не затирался, проверяется, что новое значение не nil
        if authorID != nil {
            postCoreData.authorID = authorID
        }
    }
    
    private func makeUserIDPredicate(userID: String) -> NSCompoundPredicate {
        let predicate = NSPredicate(format: "id == '\(userID)'")
        return NSCompoundPredicate(andPredicateWithSubpredicates: [predicate])
    }
    
    private func makeAuthorPostIDPredicate(authorID: String) -> NSCompoundPredicate {
        let predicate = NSPredicate(format: "authorID == '\(authorID)'")
        return NSCompoundPredicate(andPredicateWithSubpredicates: [predicate])
    }
    
    private func makePostIDPredicate(postID: String) -> NSCompoundPredicate {
        let predicate = NSPredicate(format: "id == '\(postID)'")
        return NSCompoundPredicate(andPredicateWithSubpredicates: [predicate])
    }
}
