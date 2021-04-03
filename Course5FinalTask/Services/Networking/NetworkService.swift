//
//  NetworkService.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 01.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

// MARK: - Protocols

protocol NetworkServiceProtocol {
    
    static var isOnline: Bool { get }
    
    static func setOnlineStatus(to status: Bool)
    
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

final class NetworkService: NetworkServiceProtocol {
    
    // MARK: - Static properties
    
    static let shared: NetworkServiceProtocol = NetworkService()
    static private(set) var isOnline = true
    
    // MARK: - Static methods
    
    static func setOnlineStatus(to status: Bool) {
        isOnline = status
    }
    
    // MARK: - Properties
    
    private let requestService: RequestServiceProtocol = RequestService.shared
    private let dataTaskService: DataTaskServiceProtocol = DataTaskService.shared
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Public methods

    func fetchCurrentUser(completion: @escaping UserResult) {
        guard let url = UserURLCreator.currentUser.url else { return }
        
        let request = requestService.request(url: url, httpMethod: .get)
        dataTaskService.dataTask(request: request, completion: completion)
    }

    func fetchUser(withID userID: String, completion: @escaping UserResult) {
        guard let url = UserURLCreator.getUser(userID: userID).url else { return }
        
        let request = requestService.request(url: url, httpMethod: .get)
        dataTaskService.dataTask(request: request, completion: completion)
    }

    func followToUser(withID userID: String, completion: @escaping UserResult) {
        guard let url = UserURLCreator.follow.url else { return }
        
        var request = requestService.request(url: url, httpMethod: .post)
        
        let userIDRequest = UserIDRequestModel(userID: userID)
        request.httpBody = try? JSONEncoder().encode(userIDRequest)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }

    func unfollowFromUser(withID userID: String, completion: @escaping UserResult) {
        guard let url = UserURLCreator.unfollow.url else { return }
        
        var request = requestService.request(url: url, httpMethod: .post)
        
        let userIDRequest = UserIDRequestModel(userID: userID)
        request.httpBody = try? JSONEncoder().encode(userIDRequest)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }

    func fetchUsersFollowingUser(withID userID: String, completion: @escaping UsersResult) {
        guard let url = UserURLCreator.followers(userID: userID).url else { return }
        
        let request = requestService.request(url: url, httpMethod: .get)
        dataTaskService.dataTask(request: request, completion: completion)
    }

    func fetchUsersFollowedByUser(withID userID: String, completion: @escaping UsersResult) {
        guard let url = UserURLCreator.followings(userID: userID).url else { return }
        
        let request = requestService.request(url: url, httpMethod: .get)
        dataTaskService.dataTask(request: request, completion: completion)
    }

    func fetchPostsOfUser(withID userID: String, completion: @escaping PostsResult) {
        guard let url = PostURLCreator.userPosts(userID: userID).url else { return }
        
        let request = requestService.request(url: url, httpMethod: .get)
        dataTaskService.dataTask(request: request, completion: completion)
    }

    func fetchFeedPosts(completion: @escaping PostsResult) {
        guard let url = PostURLCreator.feed.url else { return }
        
        let request = requestService.request(url: url, httpMethod: .get)
        dataTaskService.dataTask(request: request, completion: completion)
    }

    func fetchPost(withID postID: String, completion: @escaping PostResult) {
        guard let url = PostURLCreator.post(postID: postID).url else { return }
        
        let request = requestService.request(url: url, httpMethod: .get)
        dataTaskService.dataTask(request: request, completion: completion)
    }

    func likePost(withID postID: String, completion: @escaping PostResult) {
        guard let url = PostURLCreator.like.url else { return }
        
        var request = requestService.request(url: url, httpMethod: .post)
        
        let postIDRequest = PostIDRequestModel(postID: postID)
        request.httpBody = try? JSONEncoder().encode(postIDRequest)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }

    func unlikePost(withID postID: String, completion: @escaping PostResult) {
        guard let url = PostURLCreator.unlike.url else { return }
        
        var request = requestService.request(url: url, httpMethod: .post)
        
        let postIDRequest = PostIDRequestModel(postID: postID)
        request.httpBody = try? JSONEncoder().encode(postIDRequest)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }

    func fetchUsersLikedPost(withID postID: String, completion: @escaping UsersResult) {
        guard let url = PostURLCreator.usersLikedPost(postID: postID).url else { return }
        
        let request = requestService.request(url: url, httpMethod: .get)
        dataTaskService.dataTask(request: request, completion: completion)
    }

    func createPost(imageData: String, description: String, completion: @escaping PostResult) {
        guard let url = PostURLCreator.create.url else { return }
        
        var request = requestService.request(url: url, httpMethod: .post)
                        
        let newPostRequest = NewPostRequestModel(image: imageData, description: description)
        request.httpBody = try? JSONEncoder().encode(newPostRequest)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
}
