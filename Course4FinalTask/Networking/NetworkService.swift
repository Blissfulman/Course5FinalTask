//
//  NetworkService.swift
//  Course4FinalTask
//
//  Created by User on 01.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

typealias TokenResult = (Result<Token, Error>) -> Void
typealias UserResult = (Result<User, Error>) -> Void
typealias UsersResult = (Result<[User], Error>) -> Void
typealias PostResult = (Result<Post, Error>) -> Void
typealias PostsResult = (Result<[Post], Error>) -> Void

protocol NetworkServiceProtocol {
    static var token: String { get set }
    
    func singIn(login: String,
                password: String,
                completion: @escaping TokenResult)
    func singOut(completion: @escaping (Result<Bool, Error>) -> Void)
    
    func getCurrentUser(completion: @escaping UserResult)
    func getUser(withID userID: String,
                 completion: @escaping UserResult)
    func followToUser(withID userID: String,
                      completion: @escaping UserResult)
    func unfollowFromUser(withID userID: String,
                          completion: @escaping UserResult)
    func getUsersFollowingUser(withID userID: String,
                               completion: @escaping UsersResult)
    func getUsersFollowedByUser(withID userID: String,
                                completion: @escaping UsersResult)
    
    func getPostsOfUser(withID userID: String,
                        completion: @escaping PostsResult)
    func getFeed(completion: @escaping PostsResult)
    func getPost(withID postID: String,
                 completion: @escaping PostResult)
    func likePost(withID postID: String,
                  completion: @escaping PostResult)
    func unlikePost(withID postID: String,
                    completion: @escaping PostResult)
    func getUsersLikedPost(withID postID: String,
                           completion: @escaping UsersResult)
    
    func createPost(image: UIImage,
                    description: String,
                    completion: @escaping PostResult)
    
    func getImage(fromURL url: URL) -> UIImage?
}

final class NetworkService: NetworkServiceProtocol {
    
    static let shared: NetworkServiceProtocol = NetworkService()
    
    static var token = ""
    
    private let urlService: URLServiceProtocol
    private let requestService: RequestServiceProtocol
    private let dataTaskService: DataTaskServiceProtocol
    
    private init(urlService: URLServiceProtocol = URLService.shared,
                 requestService: RequestServiceProtocol = RequestService.shared,
                 dataTaskService: DataTaskServiceProtocol = DataTaskService.shared) {
        self.urlService = urlService
        self.requestService = requestService
        self.dataTaskService = dataTaskService
    }
    
    /// Запрос авторизации пользователя и получения токена.
    /// - Parameters:
    ///   - login: Логин пользователя.
    ///   - password: Пароль пользователя.
    ///   - completion: Замыкание, в которое возвращается токен авторизованного пользователя.
    ///   Вызывается после выполнения запроса.
    func singIn(login: String,
                password: String,
                completion: @escaping TokenResult) {
        
        guard let url = urlService.getURL(forPath: TokenPath.signIn) else { return }
        
        var request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.post)
        
        let authorization = Authorization(login: login, password: password)
        request.httpBody = try? JSONEncoder().encode(authorization)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Деавторизует пользователя и инвалидирует токен.
    /// - Parameter completion: Замыкание, вызываемое после выполнения запроса.
    func singOut(completion: @escaping (Result<Bool, Error>) -> Void) {
        
        guard let url = urlService.getURL(forPath: TokenPath.signOut) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.post)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Получение текущего пользователя.
    /// - Parameter completion: Замыкание, в которое возвращается текущий пользователь.
    ///   Вызывается после выполнения запроса.
    func getCurrentUser(completion: @escaping UserResult) {
        
        guard let url = urlService
                .getURL(forPath: UserPath.currentUser) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.get)
                
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Получение пользователя с указанным ID.
    /// - Parameters:
    ///   - userID: ID пользователя.
    ///   - completion: Замыкание, в которое возвращается запрашиваемый пользователь.
    ///   Вызывается после выполнения запроса.
    func getUser(withID userID: String,
                 completion: @escaping UserResult) {
        
        guard let url = urlService
                .getURL(forPath: UserPath.users + userID) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.get)
                
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Подписывает текущего пользователя на пользователя с указанным ID.
    /// - Parameters:
    ///   - userID: ID пользователя.
    ///   - completion: Замыкание, в которое возвращается пользователь, на которого подписался текущий пользователь.
    ///   Вызывается после выполнения запроса.
    func followToUser(withID userID: String,
                      completion: @escaping UserResult) {
        
        guard let url = urlService.getURL(forPath: UserPath.follow) else { return }
        
        var request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.post)
        
        let userIDRequest = UserIDRequest(userID: userID)
        request.httpBody = try? JSONEncoder().encode(userIDRequest)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Отписывает текущего пользователя от пользователя с указанным ID.
    /// - Parameters:
    ///   - userID: ID пользователя.
    ///   - completion: Замыкание, в которое возвращается пользователь, от которого отписался текущий пользователь.
    ///   Вызывается после выполнения запроса.
    func unfollowFromUser(withID userID: String,
                          completion: @escaping UserResult) {
        
        guard let url = urlService.getURL(forPath: UserPath.unfollow) else { return }
        
        var request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.post)
        
        let userIDRequest = UserIDRequest(userID: userID)
        request.httpBody = try? JSONEncoder().encode(userIDRequest)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Получение всех подписчиков пользователя с указанным ID.
    /// - Parameters:
    ///   - userID: ID пользователя.
    ///   - completion: Замыкание, в которое возвращаются запрашиваемые пользователи.
    ///   Вызывается после выполнения запроса.
    func getUsersFollowingUser(withID userID: String,
                               completion: @escaping UsersResult) {
        
        guard let url = urlService.getURL(
                forPath: UserPath.users + userID + UserPath.followers
        ) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.get)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Получение всех подписок пользователя с указанным ID.
    /// - Parameters:
    ///   - userID: ID пользователя.
    ///   - completion: Замыкание, в которое возвращаются запрашиваемые пользователи.
    ///   Вызывается после выполнения запроса.
    func getUsersFollowedByUser(withID userID: String,
                                completion: @escaping UsersResult) {
        
        guard let url = urlService.getURL(
                forPath: UserPath.users + userID + UserPath.following
        ) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.get)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Получение публикаций пользователя с указанным ID.
    /// - Parameters:
    ///   - userID: ID пользователя.
    ///   - completion: Замыкание, в которое возвращаются запрашиваемые публикации.
    ///   Вызывается после выполнения запроса.
    func getPostsOfUser(withID userID: String,
                        completion: @escaping PostsResult) {
        
        guard let url = urlService.getURL(
                forPath: UserPath.users + userID + PostPath.posts
        ) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.get)
                
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Получение публикаций пользователей, на которых подписан текущий пользователь.
    /// - Parameter completion: Замыкание, в которое возвращаются запрашиваемые публикации.
    ///   Вызывается после выполнения запроса.
    func getFeed(completion: @escaping PostsResult) {
        
        guard let url = urlService.getURL(forPath: PostPath.feed) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.get)
                
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Получение публикации с указанным ID.
    /// - Parameters:
    ///   - postID: ID поста.
    ///   - completion: Замыкание, в которое возвращается запрашиваемая публикация.
    ///   Вызывается после выполнения запроса.
    func getPost(withID postID: String,
                 completion: @escaping PostResult) {
        
        guard let url = urlService
                .getURL(forPath: PostPath.posts + postID) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.get)
                
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Ставит лайк от текущего пользователя на публикации с указанным ID.
    /// - Parameters:
    ///   - postID: ID поста.
    ///   - completion: Замыкание, в которое возвращается публикация, которой был поставлен лайк.
    ///   Вызывается после выполнения запроса.
    func likePost(withID postID: String,
                  completion: @escaping PostResult) {
        
        guard let url = urlService
                .getURL(forPath: PostPath.like) else { return }
        
        var request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.post)
        
        let postIDRequest = PostIDRequest(postID: postID)
        request.httpBody = try? JSONEncoder().encode(postIDRequest)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Удаляет лайк от текущего пользователя на публикации с указанным ID.
    /// - Parameters:
    ///   - postID: ID поста.
    ///   - completion: Замыкание, в которое возвращается публикация, которой был поставлен анлайк.
    ///   Вызывается после выполнения запроса.
    func unlikePost(withID postID: String,
                    completion: @escaping PostResult) {
        
        guard let url = urlService
                .getURL(forPath: PostPath.unlike) else { return }
        
        var request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.post)
        
        let postIDRequest = PostIDRequest(postID: postID)
        request.httpBody = try? JSONEncoder().encode(postIDRequest)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Получение пользователей, поставивших лайк на публикацию с указанным ID.
    /// - Parameters:
    ///   - postID: ID поста.
    ///   - completion: Замыкание, в которое возвращаются запрашиваемые пользователи.
    ///   Вызывается после выполнения запроса.
    func getUsersLikedPost(withID postID: String,
                           completion: @escaping UsersResult) {
        
        guard let url = urlService.getURL(
                forPath: PostPath.posts + postID + PostPath.likes
        ) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.get)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Создание новой публикации.
    /// - Parameters:
    ///   - image: Изображение публикации.
    ///   - description: Описание публикации.
    ///   - completion: Замыкание, в которое возвращаются опубликованная публикация.
    ///   Вызывается после выполнения запроса.
    func createPost(image: UIImage,
                    description: String,
                    completion: @escaping PostResult) {
        
        guard let url = urlService.getURL(forPath: PostPath.create) else { return }
        
        var request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.post)
                        
        let newPostRequest = NewPostRequest(image: image.encodeToBase64(),
                                            description: description)
        request.httpBody = try? JSONEncoder().encode(newPostRequest)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Получение изображения по URL.
    func getImage(fromURL url: URL) -> UIImage? {
        guard let imageData = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: imageData)
    }
}
