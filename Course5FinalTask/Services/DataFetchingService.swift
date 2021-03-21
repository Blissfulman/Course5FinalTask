//
//  DataFetchingService.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 09.03.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

// MARK: - Protocols

typealias UserResult = (Result<UserModel, Error>) -> Void
typealias UsersResult = (Result<[UserModel], Error>) -> Void
typealias PostResult = (Result<PostModel, Error>) -> Void
typealias PostsResult = (Result<[PostModel], Error>) -> Void

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
    ///   - postID: ID поста.
    ///   - completion: Замыкание, в которое возвращается запрашиваемая публикация.
    ///   Вызывается после выполнения запроса.
    func fetchPost(withID postID: String, completion: @escaping PostResult)
    
    /// Ставит лайк от текущего пользователя на публикации с указанным ID.
    /// - Parameters:
    ///   - postID: ID поста.
    ///   - completion: Замыкание, в которое возвращается публикация, которой был поставлен лайк.
    ///   Вызывается после выполнения запроса.
    func likePost(withID postID: String, completion: @escaping PostResult)
    
    /// Удаляет лайк от текущего пользователя на публикации с указанным ID.
    /// - Parameters:
    ///   - postID: ID поста.
    ///   - completion: Замыкание, в которое возвращается публикация, которой был поставлен анлайк.
    ///   Вызывается после выполнения запроса.
    func unlikePost(withID postID: String, completion: @escaping PostResult)
    
    /// Получение пользователей, поставивших лайк на публикацию с указанным ID.
    /// - Parameters:
    ///   - postID: ID поста.
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
    private let offlineError = AppError.offlineError
    
    // MARK: - Initializers
    
    private init() {
        isOnline = NetworkService.isOnline
    }
    
    // MARK: - Public methods
    
    func fetchCurrentUser(completion: @escaping UserResult) {
        guard isOnline else {
            guard let currentUser = dataStorageService.getCurrentUser() else {
                print("Current user didn't get!!!") // TEMP
                return
            }
            print(currentUser)
            DispatchQueue.main.async {
                completion(.success(currentUser))
            }
            return
        }
        
        networkService.fetchCurrentUser { [weak self] result in
            switch result {
            case .success(let currentUser):
                completion(.success(currentUser))
                DispatchQueue.global().async {
                    self?.dataStorageService.saveUser(currentUser)
                    print("Current user saved!!!") // TEMP
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchUser(withID userID: String, completion: @escaping UserResult) {
        guard isOnline else {
            guard let currentUser = dataStorageService.getCurrentUser() else {
                print("Current user didn't get!!!") // TEMP
                return
            }
            print(currentUser)
            DispatchQueue.main.async {
                completion(.success(currentUser))
            }
            return
        }
        
        if isOnline {
            networkService.fetchUser(withID: userID, completion: completion)
        }
    }
    
    func followToUser(withID userID: String, completion: @escaping UserResult) {
        isOnline
            ? networkService.followToUser(withID: userID, completion: completion)
            : completion(.failure(offlineError))
    }
    
    func unfollowFromUser(withID userID: String, completion: @escaping UserResult) {
        isOnline
            ? networkService.unfollowFromUser(withID: userID, completion: completion)
            : completion(.failure(offlineError))
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
        guard isOnline else {
            let currentUserPosts = dataStorageService.getPostsOfUser(withID: userID)
            print("currentUserPosts.count: ", currentUserPosts.count) // TEMP
            DispatchQueue.main.async {
                completion(.success(currentUserPosts))
            }
            return
        }
        
        networkService.fetchPostsOfUser(withID: userID, completion: completion)
    }
    
    func fetchFeedPosts(completion: @escaping PostsResult) {
        guard isOnline else {
            completion(.success(dataStorageService.getAllPosts()))
            return
        }
        
        networkService.fetchFeedPosts { [weak self] result in
            switch result {
            case .success(let feedPosts):
                completion(.success(feedPosts))
                DispatchQueue.global().async {
                    self?.dataStorageService.savePosts(feedPosts)
                }
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
            ? networkService.likePost(withID: postID, completion: completion)
            : completion(.failure(offlineError))
    }
    
    func unlikePost(withID postID: String, completion: @escaping PostResult) {
        isOnline
            ? networkService.unlikePost(withID: postID, completion: completion)
            : completion(.failure(offlineError))
    }
    
    func fetchUsersLikedPost(withID postID: String, completion: @escaping UsersResult) {
        if isOnline {
            networkService.fetchUsersLikedPost(withID: postID, completion: completion)
        }
    }
    
    func createPost(imageData: String, description: String, completion: @escaping PostResult) {
        isOnline
            ? networkService.createPost(imageData: imageData, description: description, completion: completion)
            : completion(.failure(offlineError))
    }
}
