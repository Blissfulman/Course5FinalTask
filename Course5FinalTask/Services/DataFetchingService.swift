//
//  DataFetchingService.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 09.03.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

typealias UserResult = (Result<UserModel, Error>) -> Void
typealias UsersResult = (Result<[UserModel], Error>) -> Void
typealias PostResult = (Result<PostModel, Error>) -> Void
typealias PostsResult = (Result<[PostModel], Error>) -> Void

// MARK: - Protocols

protocol DataFetchingServiceProtocol {
    
    /// Получение текущего пользователя.
    /// - Parameter completion: Замыкание, в которое возвращается текущий пользователь.
    ///   Вызывается после выполнения запроса.
    func fetchCurrentUser(completion: @escaping UserResult)
    
    /// Получение пользователя с указанным ID.
    /// - Parameters:
    ///   - userID: ID пользователя.
    ///   - completion: Замыкание, в которое возвращается запрашиваемый пользователь.
    ///   Вызывается после выполнения запроса.
    func fetchUser(withID userID: String, completion: @escaping UserResult)
    
    /// Подписывает текущего пользователя на пользователя с указанным ID.
    /// - Parameters:
    ///   - userID: ID пользователя.
    ///   - completion: Замыкание, в которое возвращается пользователь, на которого подписался текущий пользователь.
    ///   Вызывается после выполнения запроса.
    func followToUser(withID userID: String, completion: @escaping UserResult)
    
    /// Отписывает текущего пользователя от пользователя с указанным ID.
    /// - Parameters:
    ///   - userID: ID пользователя.
    ///   - completion: Замыкание, в которое возвращается пользователь, от которого отписался текущий пользователь.
    ///   Вызывается после выполнения запроса.
    func unfollowFromUser(withID userID: String, completion: @escaping UserResult)
    
    /// Получение всех подписчиков пользователя с указанным ID.
    /// - Parameters:
    ///   - userID: ID пользователя.
    ///   - completion: Замыкание, в которое возвращаются запрашиваемые пользователи.
    ///   Вызывается после выполнения запроса.
    func fetchUsersFollowingUser(withID userID: String, completion: @escaping UsersResult)
    
    /// Получение всех подписок пользователя с указанным ID.
    /// - Parameters:
    ///   - userID: ID пользователя.
    ///   - completion: Замыкание, в которое возвращаются запрашиваемые пользователи.
    ///   Вызывается после выполнения запроса.
    func fetchUsersFollowedByUser(withID userID: String, completion: @escaping UsersResult)
    
    /// Получение публикаций пользователя с указанным ID.
    /// - Parameters:
    ///   - userID: ID пользователя.
    ///   - completion: Замыкание, в которое возвращаются запрашиваемые публикации.
    ///   Вызывается после выполнения запроса.
    func fetchPostsOfUser(withID userID: String, completion: @escaping PostsResult)
    
    /// Получение публикаций пользователей, на которых подписан текущий пользователь.
    /// - Parameter completion: Замыкание, в которое возвращаются запрашиваемые публикации.
    ///   Вызывается после выполнения запроса.
    func fetchFeedPosts(completion: @escaping PostsResult)
    
    /// Получение публикации с указанным ID.
    /// - Parameters:
    ///   - postID: ID публикации.
    ///   - completion: Замыкание, в которое возвращается запрашиваемая публикация.
    ///   Вызывается после выполнения запроса.
    func fetchPost(withID postID: String, completion: @escaping PostResult)
    
    /// Ставит лайк от текущего пользователя на публикации с указанным ID.
    /// - Parameters:
    ///   - postID: ID публикации.
    ///   - completion: Замыкание, в которое возвращается публикация, которой был поставлен лайк.
    ///   Вызывается после выполнения запроса.
    func likePost(withID postID: String, completion: @escaping PostResult)
    
    /// Удаляет лайк от текущего пользователя на публикации с указанным ID.
    /// - Parameters:
    ///   - postID: ID публикации.
    ///   - completion: Замыкание, в которое возвращается публикация, которой был поставлен анлайк.
    ///   Вызывается после выполнения запроса.
    func unlikePost(withID postID: String, completion: @escaping PostResult)
    
    /// Получение пользователей, поставивших лайк на публикацию с указанным ID.
    /// - Parameters:
    ///   - postID: ID публикации.
    ///   - completion: Замыкание, в которое возвращаются запрашиваемые пользователи.
    ///   Вызывается после выполнения запроса.
    func fetchUsersLikedPost(withID postID: String, completion: @escaping UsersResult)
    
    /// Создание новой публикации.
    /// - Parameters:
    ///   - image: Изображение публикации.
    ///   - description: Описание публикации.
    ///   - completion: Замыкание, в которое возвращаются опубликованная публикация.
    ///   Вызывается после выполнения запроса.
    func createPost(imageData: String, description: String, completion: @escaping PostResult)
}

final class DataFetchingService: DataFetchingServiceProtocol {
    
    // MARK: - Static properties
    
    static let shared: DataFetchingServiceProtocol = DataFetchingService()
    
    // MARK: - Properties
    
    private let networkService: NetworkServiceProtocol = NetworkService.shared
    private let dataStorageService: DataStorageServiceProtocol = DataStorageService.shared
    private let isOnline: Bool
    private let offlineMode = AppError.offlineMode
    private let noOfflineDataError = AppError.noOfflineData
    
    // MARK: - Initializers
    
    private init() {
        isOnline = NetworkService.isOnline
    }
    
    // MARK: - Public methods
    
    func fetchCurrentUser(completion: @escaping UserResult) {
        // В оффлайне вернётся текущий пользователь, если он и его ID были сохранены
        guard isOnline else {
            guard let currentUser = dataStorageService.getCurrentUser() else {
                completion(.failure(noOfflineDataError))
                return
            }
            DispatchQueue.main.async {
                completion(.success(currentUser))
            }
            return
        }
        
        // В онлайне вернётся и сохранится текущий пользователь
        networkService.fetchCurrentUser { [unowned self] result in
            switch result {
            case .success(let currentUser):
                completion(.success(currentUser))
                dataStorageService.saveCurrentUser(currentUser)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchUser(withID userID: String, completion: @escaping UserResult) {
        // В оффлайне вернётся пользователь с переданным ID, если он был сохранён
        guard isOnline else {
            guard let user = dataStorageService.getUser(withID: userID) else {
                completion(.failure(noOfflineDataError))
                return
            }
            DispatchQueue.main.async {
                completion(.success(user))
            }
            return
        }
        
        // В онлайне вернётся и сохранится пользователь с переданным ID
        networkService.fetchUser(withID: userID) { [unowned self] result in
            switch result {
            case .success(let user):
                completion(.success(user))
                dataStorageService.saveUser(user)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func followToUser(withID userID: String, completion: @escaping UserResult) {
        isOnline
            ? networkService.followToUser(withID: userID, completion: completion)
            : completion(.failure(offlineMode))
    }
    
    func unfollowFromUser(withID userID: String, completion: @escaping UserResult) {
        isOnline
            ? networkService.unfollowFromUser(withID: userID, completion: completion)
            : completion(.failure(offlineMode))
    }
    
    func fetchUsersFollowingUser(withID userID: String, completion: @escaping UsersResult) {
        if isOnline {
            networkService.fetchUsersFollowingUser(withID: userID, completion: completion)
        }
    }
    
    func fetchUsersFollowedByUser(withID userID: String, completion: @escaping UsersResult) {
        if isOnline {
            networkService.fetchUsersFollowedByUser(withID: userID, completion: completion)
        }
    }
    
    func fetchPostsOfUser(withID userID: String, completion: @escaping PostsResult) {
        // В оффлайне вернутся публикации пользователя с переданным ID, если они были сохранены
        guard isOnline else {
            let currentUserPosts = dataStorageService.getPostsOfUser(withID: userID)
            DispatchQueue.main.async {
                completion(.success(currentUserPosts))
            }
            return
        }
        
        // В оффлайне вернутся и сохранятся публикации пользователя с переданным ID
        networkService.fetchPostsOfUser(withID: userID) { [unowned self] result in
            switch result {
            case .success(let userPosts):
                completion(.success(userPosts))
                dataStorageService.savePosts(userPosts, asFeedPosts: false)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchFeedPosts(completion: @escaping PostsResult) {
        // В оффлайне вернутся публикации ленты, если они были сохранены
        guard isOnline else {
            DispatchQueue.main.async {
                completion(.success(self.dataStorageService.getFeedPosts()))
            }
            return
        }
        
        // В онлайне вернутся и сохранятся публикации ленты
        networkService.fetchFeedPosts { [unowned self] result in
            switch result {
            case .success(let feedPosts):
                completion(.success(feedPosts))
                dataStorageService.savePosts(feedPosts, asFeedPosts: true)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchPost(withID postID: String, completion: @escaping PostResult) {
        if isOnline {
            networkService.fetchPost(withID: postID, completion: completion)
        }
    }
    
    func likePost(withID postID: String, completion: @escaping PostResult) {
        isOnline
            ? networkService.likePost(withID: postID) { [unowned self] result in
                switch result {
                case .success(let post):
                    completion(.success(post))
                    dataStorageService.savePosts([post], asFeedPosts: false)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            : completion(.failure(offlineMode))
    }
    
    func unlikePost(withID postID: String, completion: @escaping PostResult) {
        isOnline
            ? networkService.unlikePost(withID: postID) { [unowned self] result in
                switch result {
                case .success(let post):
                    completion(.success(post))
                    dataStorageService.savePosts([post], asFeedPosts: false)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            : completion(.failure(offlineMode))
    }
    
    func fetchUsersLikedPost(withID postID: String, completion: @escaping UsersResult) {
        if isOnline {
            networkService.fetchUsersLikedPost(withID: postID, completion: completion)
        }
    }
    
    func createPost(imageData: String, description: String, completion: @escaping PostResult) {
        isOnline
            ? networkService.createPost(imageData: imageData,
                                        description: description,
                                        completion: completion)
            : completion(.failure(offlineMode))
    }
}
