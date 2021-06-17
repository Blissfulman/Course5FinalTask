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
    
    /// Сохранение всех несохранённых данных.
    func saveData()
    
    /// Сохранение пользователя.
    /// - Parameter userModel: Пользователь.
    func saveUser(_ userModel: UserModel)
    
    /// Сохранение текущего пользователя.
    /// - Parameter userModel: Пользователь.
    func saveCurrentUser(_ userModel: UserModel)
    
    /// Сохранение публикаций.
    /// - Parameters:
    ///   - postModels: Публикации.
    ///   - asFeedPosts: Свойство, свидетельствующее о том, что передаваемые публикации, являются публикациями ленты.
    func savePosts(_ postModels: [PostModel], asFeedPosts: Bool)
    
    /// Получение текущего пользователя.
    func getCurrentUser() -> UserModel?
    
    /// Получение пользователя с указанным ID.
    /// - Parameter userID: ID пользователя.
    func getUser(withID userID: UserModel.ID) -> UserModel?
    
    /// Получение публикаций ленты.
    func getFeedPosts() -> [PostModel]
    
    /// Получение публикаций пользователя с указанным ID.
    /// - Parameter userID: ID пользователя.
    func getPostsOfUser(withID userID: UserModel.ID) -> [PostModel]
    
    /// Удаление всех сохранённых данных.
    func deleteAllData()
}

final class DataStorageService: DataStorageServiceProtocol {
    
    // MARK: - Static properties
    
    static let shared = DataStorageService()
    
    // MARK: - Properties
    
    private let coreDataService = CoreDataService(modelName: "Course5FinalTask")
    
    // MARK: - Public methods
    
    func saveData() {
        coreDataService.saveChanges()
    }
    
    func saveCurrentUser(_ userModel: UserModel) {
        // Сохранение ID текущего пользователя в случае его отсутствия в хранилище
        if coreDataService.fetchData(for: CurrentUser.self).isEmpty {
            coreDataService.createObject(from: CurrentUser.self) { currentUser in
                currentUser.id = userModel.id
            }
        }
        saveUser(userModel)
    }
    
    func saveUser(_ userModel: UserModel) {
        coreDataService.createObject(from: UserCoreData.self) { [unowned self] newUserCoreData in
            fillUserCoreData(newUserCoreData, from: userModel)
            saveData()
        }
    }
    
    func savePosts(_ postModels: [PostModel], asFeedPosts: Bool) {
        postModels.forEach { postModel in
            coreDataService.createObject(from: PostCoreData.self) { [unowned self] newPostCoreData in
                fillPostCoreData(newPostCoreData, from: postModel)
                saveData()
            }
        }
        if asFeedPosts {
            saveFeedPostIDs(postModels)
        }
    }
    
    func getCurrentUser() -> UserModel? {
        guard let currentUserID = getCurrentUserID(),
              let currentUser = getUser(withID: currentUserID) else { return nil }
        return currentUser
    }
    
    func getUser(withID userID: UserModel.ID) -> UserModel? {
        let users = coreDataService.fetchData(for: UserCoreData.self, predicate: makeUserIDPredicate(userID: userID))
        return UserModel(userCoreData: users.first)
    }
    
    func getFeedPosts() -> [PostModel] {
        // Получение массива идентификаторов публикаций ленты
        let feedPostIDs = getFeedPostIDs()
        // Получение публикаций ленты из хранилища по их ID
        let feedPosts = feedPostIDs.compactMap {
            coreDataService.fetchData(for: PostCoreData.self, predicate: makePostIDPredicate(postID: $0)).first
        }
        return feedPosts.compactMap { PostModel(postCoreData: $0) }
    }
    
    func getPostsOfUser(withID userID: UserModel.ID) -> [PostModel] {
        let posts = coreDataService.fetchData(
            for: PostCoreData.self,
            predicate: makeAuthorPostIDPredicate(authorID: userID)
        )
        return posts.compactMap { PostModel(postCoreData: $0) }
    }
    
    func deleteAllData() {
        deleteAllUsers()
        deleteAllCurrentUsers()
        deleteAllPosts()
        deleteFeedPostIDs()
    }
    
    // MARK: - Private methods
    
    private func saveFeedPostIDs(_ postModels: [PostModel]) {
        deleteFeedPostIDs()
        let feedPostIDs = postModels.map { $0.id }
        coreDataService.createObject(from: Feed.self) { [unowned self] feed in
            feed.postIDs = feedPostIDs.description.data(using: .utf16)
            saveData()
        }
    }
    
    private func getFeedPostIDs() -> [PostModel.ID] {
        guard let feedPostIDsData = coreDataService.fetchData(for: Feed.self).first?.postIDs,
              let feedPostIDs = try? JSONDecoder().decode([PostModel.ID].self, from: feedPostIDsData) else { return [] }
        return feedPostIDs
    }
    
    private func getCurrentUserID() -> UserModel.ID? {
        let currentUsers = coreDataService.fetchData(for: CurrentUser.self)
        return currentUsers.first?.id ?? nil
    }
    
    private func deleteAllUsers() {
        let users = coreDataService.fetchData(for: UserCoreData.self)
        coreDataService.deleteObjects(users)
    }
    
    private func deleteAllCurrentUsers() {
        let currentUsers = coreDataService.fetchData(for: CurrentUser.self)
        coreDataService.deleteObjects(currentUsers)
    }
    
    private func deleteAllPosts() {
        let posts = coreDataService.fetchData(for: PostCoreData.self)
        coreDataService.deleteObjects(posts)
    }
    
    private func deleteFeedPostIDs() {
        let feed = coreDataService.fetchData(for: Feed.self)
        coreDataService.deleteObjects(feed)
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
    
    private func makeUserIDPredicate(userID: UserModel.ID) -> NSCompoundPredicate {
        let predicate = NSPredicate(format: "id == '\(userID)'")
        return NSCompoundPredicate(andPredicateWithSubpredicates: [predicate])
    }
    
    private func makeAuthorPostIDPredicate(authorID: UserModel.ID) -> NSCompoundPredicate {
        let predicate = NSPredicate(format: "author == '\(authorID)'")
        return NSCompoundPredicate(andPredicateWithSubpredicates: [predicate])
    }
    
    private func makePostIDPredicate(postID: UserModel.ID) -> NSCompoundPredicate {
        let predicate = NSPredicate(format: "id == '\(postID)'")
        return NSCompoundPredicate(andPredicateWithSubpredicates: [predicate])
    }
}
