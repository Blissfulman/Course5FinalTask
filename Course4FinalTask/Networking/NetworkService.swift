//
//  NetworkService.swift
//  Course4FinalTask
//
//  Created by User on 01.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import UIKit

typealias TokenResult = (Result<Token, Error>) -> Void
typealias UserResult = (Result<User, Error>) -> Void
typealias UsersResult = (Result<[User], Error>) -> Void
typealias PostResult = (Result<Post, Error>) -> Void
typealias PostsResult = (Result<[Post], Error>) -> Void

protocol NetworkServiceProtocol {
    func singIn(login: String,
                password: String,
                completion: @escaping TokenResult)
    func singOut(token: String,
                 completion: @escaping (Result<Bool, Error>) -> Void)
    
    func getCurrentUser(token: String,
                        completion: @escaping UserResult)
    func getUser(withID userID: String,
                 token: String,
                 completion: @escaping UserResult)
    func followToUser(withID userID: String,
                      token: String,
                      completion: @escaping UserResult)
    func unfollowFromUser(withID userID: String,
                          token: String,
                          completion: @escaping UserResult)
    func getUsersFollowingUser(withID userID: String,
                               token: String,
                               completion: @escaping UsersResult)
    func getUsersFollowedByUser(withID userID: String,
                                token: String,
                                completion: @escaping UsersResult)
    
    func getPostsOfUser(withID userID: String,
                        token: String,
                        completion: @escaping PostsResult)
    func getFeed(token: String, completion: @escaping PostsResult)
    func getPost(withID postID: String,
                 token: String,
                 completion: @escaping PostResult)
    func likePost(withID postID: String,
                  token: String,
                  completion: @escaping PostResult)
    func unlikePost(withID postID: String,
                    token: String,
                    completion: @escaping PostResult)
    func getUsersLikedPost(withID postID: String,
                           token: String,
                           completion: @escaping UsersResult)
    
    func getImage(fromURL url: URL) -> UIImage?
}

final class NetworkService: NetworkServiceProtocol {
    
    private let urlService: URLServiceProtocol
    private let requestService: RequestServiceProtocol
    private let dataTaskService: DataTaskServiceProtocol
    
    static let shared: NetworkServiceProtocol = NetworkService()
    
    
    
    private init(urlService: URLServiceProtocol = URLService(),
                 requestService: RequestServiceProtocol = RequestService(),
                 dataTaskService: DataTaskServiceProtocol = DataTaskService()) {
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
                                             httpMethod: HTTPMethod.post,
                                             token: nil)
        
        let authorization = Authorization(login: login, password: password)
        request.httpBody = try? JSONEncoder().encode(authorization)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Деавторизует пользователя и инвалидирует токен.
    /// - Parameter token: Токен текущего пользователя.
    /// - Parameter completion: Замыкание, вызываемое после выполнения запроса.
    func singOut(token: String,
                 completion: @escaping (Result<Bool, Error>) -> Void) {
        
        guard let url = urlService.getURL(forPath: TokenPath.signOut) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.post,
                                             token: token)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Получение текущего пользователя.
    /// - Parameters:
    ///   - token: Токен текущего пользователя.
    ///   - completion: Замыкание, в которое возвращается текущий пользователь.
    ///   Вызывается после выполнения запроса.
    func getCurrentUser(token: String,
                        completion: @escaping UserResult) {
        
        guard let url = urlService
                .getURL(forPath: UserPath.currentUser) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.get,
                                             token: token)
                
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Получение пользователя с указанным ID.
    /// - Parameters:
    ///   - userID: ID пользователя.
    ///   - token: Токен текущего пользователя.
    ///   - completion: Замыкание, в которое возвращается запрашиваемый пользователь.
    ///   Вызывается после выполнения запроса.
    func getUser(withID userID: String,
                 token: String,
                 completion: @escaping UserResult) {
        
        guard let url = urlService
                .getURL(forPath: UserPath.users + userID) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.get,
                                             token: token)
                
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Подписывает текущего пользователя на пользователя с указанным ID.
    /// - Parameters:
    ///   - userID: ID пользователя.
    ///   - token: Токен текущего пользователя.
    ///   - completion: Замыкание, в которое возвращается пользователь, на которого подписался текущий пользователь.
    ///   Вызывается после выполнения запроса.
    func followToUser(withID userID: String,
                      token: String,
                      completion: @escaping UserResult) {
        
        guard let url = urlService.getURL(forPath: UserPath.follow) else { return }
        
        var request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.post,
                                             token: token)
        
        let userIDRequest = UserIDRequest(userID: userID)
        request.httpBody = try? JSONEncoder().encode(userIDRequest)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Отписывает текущего пользователя от пользователя с указанным ID.
    /// - Parameters:
    ///   - userID: ID пользователя.
    ///   - token: Токен текущего пользователя.
    ///   - completion: Замыкание, в которое возвращается пользователь, от которого отписался текущий пользователь.
    ///   Вызывается после выполнения запроса.
    func unfollowFromUser(withID userID: String,
                          token: String,
                          completion: @escaping UserResult) {
        
        guard let url = urlService.getURL(forPath: UserPath.unfollow) else { return }
        
        var request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.post,
                                             token: token)
        
        let userIDRequest = UserIDRequest(userID: userID)
        request.httpBody = try? JSONEncoder().encode(userIDRequest)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Получение всех подписчиков пользователя с указанным ID.
    /// - Parameters:
    ///   - userID: ID пользователя.
    ///   - token: Токен текущего пользователя.
    ///   - completion: Замыкание, в которое возвращаются запрашиваемые пользователи.
    ///   Вызывается после выполнения запроса.
    func getUsersFollowingUser(withID userID: String,
                               token: String,
                               completion: @escaping UsersResult) {
        
        guard let url = urlService.getURL(
                forPath: UserPath.users + userID + UserPath.followers
        ) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.get,
                                             token: token)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Получение всех подписок пользователя с указанным ID.
    /// - Parameters:
    ///   - userID: ID пользователя.
    ///   - token: Токен текущего пользователя.
    ///   - completion: Замыкание, в которое возвращаются запрашиваемые пользователи.
    ///   Вызывается после выполнения запроса.
    func getUsersFollowedByUser(withID userID: String,
                                token: String,
                                completion: @escaping UsersResult) {
        
        guard let url = urlService.getURL(
                forPath: UserPath.users + userID + UserPath.following
        ) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.get,
                                             token: token)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Получение публикаций пользователя с указанным ID.
    /// - Parameters:
    ///   - userID: ID пользователя.
    ///   - token: Токен текущего пользователя.
    ///   - completion: Замыкание, в которое возвращаются запрашиваемые публикации.
    ///   Вызывается после выполнения запроса.
    func getPostsOfUser(withID userID: String,
                        token: String,
                        completion: @escaping PostsResult) {
        
        guard let url = urlService.getURL(
                forPath: UserPath.users + userID + PostPath.posts
        ) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.get,
                                             token: token)
                
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Получение публикаций пользователей, на которых подписан текущий пользователь.
    /// - Parameters:
    ///   - token: Токен текущего пользователя.
    ///   - completion: Замыкание, в которое возвращаются запрашиваемые публикации.
    ///   Вызывается после выполнения запроса.
    func getFeed(token: String, completion: @escaping PostsResult) {
        
        guard let url = urlService.getURL(forPath: PostPath.feed) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.get,
                                             token: token)
                
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Получение публикации с указанным ID.
    /// - Parameters:
    ///   - postID: ID поста.
    ///   - token: Токен текущего пользователя.
    ///   - completion: Замыкание, в которое возвращается запрашиваемая публикация.
    ///   Вызывается после выполнения запроса.
    func getPost(withID postID: String,
                 token: String,
                 completion: @escaping PostResult) {
        
        guard let url = urlService
                .getURL(forPath: PostPath.posts + postID) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.get,
                                             token: token)
                
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Ставит лайк от текущего пользователя на публикации с указанным ID.
    /// - Parameters:
    ///   - postID: ID поста.
    ///   - token: Токен текущего пользователя.
    ///   - completion: Замыкание, в которое возвращается пост, которому был поставлен лайк.
    ///   Вызывается после выполнения запроса.
    func likePost(withID postID: String,
                  token: String,
                  completion: @escaping PostResult) {
        
        guard let url = urlService
                .getURL(forPath: PostPath.like) else { return }
        
        var request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.post,
                                             token: token)
        
        let postIDRequest = PostIDRequest(postID: postID)
        request.httpBody = try? JSONEncoder().encode(postIDRequest)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Удаляет лайк от текущего пользователя на публикации с указанным ID.
    /// - Parameters:
    ///   - postID: ID поста.
    ///   - token: Токен текущего пользователя.
    ///   - completion: Замыкание, в которое возвращается пост, которому был поставлен анлайк.
    ///   Вызывается после выполнения запроса.
    func unlikePost(withID postID: String,
                    token: String,
                    completion: @escaping PostResult) {
        
        guard let url = urlService
                .getURL(forPath: PostPath.unlike) else { return }
        
        var request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.post,
                                             token: token)
        
        let postIDRequest = PostIDRequest(postID: postID)
        request.httpBody = try? JSONEncoder().encode(postIDRequest)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Получение пользователей, поставивших лайк на публикацию с указанным ID.
    /// - Parameters:
    ///   - postID: ID поста.
    ///   - token: Токен текущего пользователя.
    ///   - completion: Замыкание, в которое возвращаются запрашиваемые пользователи.
    ///   Вызывается после выполнения запроса.
    func getUsersLikedPost(withID postID: String,
                           token: String,
                           completion: @escaping UsersResult) {
        
        guard let url = urlService.getURL(
                forPath: PostPath.posts + postID + PostPath.likes
        ) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.get,
                                             token: token)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Получение изображения по URL.
    func getImage(fromURL url: URL) -> UIImage? {
        guard let imageData = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: imageData)
    }
}
