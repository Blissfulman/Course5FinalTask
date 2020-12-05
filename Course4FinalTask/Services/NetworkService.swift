//
//  NetworkService.swift
//  Course4FinalTask
//
//  Created by User on 01.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import UIKit

protocol NetworkServiceProtocol {
    func singIn(login: String,
                password: String,
                completion: @escaping (Token?) -> Void)
    func getUser(withID userID: String,
                 token: String,
                 completion: @escaping (User?) -> Void)
    func getCurrentUser(token: String,
                        completion: @escaping (User?) -> Void)
    func getPostsOfUser(withID userID: String,
                        token: String,
                        completion: @escaping ([Post]?) -> Void)
    func getFeed(token: String, completion: @escaping ([Post]?) -> Void)
    func getPost(withID postID: String,
                 token: String,
                 completion: @escaping (Post?) -> Void)
    func likePost(withID postID: String,
                  token: String,
                  completion: @escaping (Post?) -> Void)
    func unlikePost(withID postID: String,
                    token: String,
                    completion: @escaping (Post?) -> Void)
    func getUsersLikedPost(withID postID: String,
                           token: String,
                           completion: @escaping ([User]?) -> Void)
    func getImage(fromURL url: URL) -> UIImage?
}

final class NetworkService: NetworkServiceProtocol {
    
    private let urlService: URLServiceProtocol
    private let requestService: RequestServiceProtocol
    private let dataTaskService: DataTaskServiceProtocol
    
    init(urlService: URLServiceProtocol = URLService(),
         requestService: RequestServiceProtocol = RequestService(),
         dataTaskService: DataTaskServiceProtocol = DataTaskService()) {
        self.urlService = urlService
        self.requestService = requestService
        self.dataTaskService = dataTaskService
    }
    
    /// Запрос авторизации пользователя.
    /// - Parameters:
    ///   - login: Логин пользователя.
    ///   - password: Пароль пользователя.
    ///   - completion: Замыкание, в которое возвращается токен авторизованного пользователя.
    ///   Вызывается после выполнения запроса.
    func singIn(login: String,
                password: String,
                completion: @escaping (Token?) -> Void) {
        
        guard let url = urlService.getURL(forPath: TokenPath.signIn) else { return }
        
        var request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.post,
                                             token: nil)
        
        let authorization = Authorization(login: login, password: password)
        
        request.httpBody = try? JSONEncoder().encode(authorization)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Получение пользователя с переданным ID.
    /// - Parameters:
    ///   - userID: ID пользователя.
    ///   - token: Токен текущего пользователя.
    ///   - completion: Замыкание, в которое возвращается запрашиваемый пользователь.
    ///   Вызывается после выполнения запроса.
    func getUser(withID userID: String,
                 token: String,
                 completion: @escaping (User?) -> Void) {
        
        guard let url = urlService
                .getURL(forPath: UserPath.users + userID) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.get,
                                             token: token)
                
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    
    /// Получение текущего пользователя.
    /// - Parameters:
    ///   - token: Токен текущего пользователя.
    ///   - completion: Замыкание, в которое возвращается текущий пользователь.
    ///   Вызывается после выполнения запроса.
    func getCurrentUser(token: String,
                        completion: @escaping (User?) -> Void) {
        
        guard let url = urlService
                .getURL(forPath: UserPath.currentUser) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.get,
                                             token: token)
                
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Получение публикаций пользователя с запрошенным ID.
    /// - Parameters:
    ///   - userID: ID пользователя.
    ///   - token: Токен текущего пользователя.
    ///   - completion: Замыкание, в которое возвращаются запрашиваемые публикации.
    ///   Вызывается после выполнения запроса.
    func getPostsOfUser(withID userID: String,
                        token: String,
                        completion: @escaping ([Post]?) -> Void) {
        
        guard let url = urlService.getURL(forPath: UserPath.users + userID + PostPath.posts) else { return }
        
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
    func getFeed(token: String, completion: @escaping ([Post]?) -> Void) {
        
        guard let url = urlService.getURL(forPath: PostPath.feed) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.get,
                                             token: token)
                
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Получение публикации с переданным ID.
    /// - Parameters:
    ///   - postID: ID поста.
    ///   - token: Токен текущего пользователя.
    ///   - completion: Замыкание, в которое возвращается запрашиваемая публикация.
    ///   Вызывается после выполнения запроса.
    func getPost(withID postID: String,
                 token: String,
                 completion: @escaping (Post?) -> Void) {
        
        guard let url = urlService
                .getURL(forPath: PostPath.posts + postID) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.get,
                                             token: token)
                
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    
    /// Ставит лайк от текущего пользователя на публикации с запрошенным ID.
    /// - Parameters:
    ///   - postID: ID поста.
    ///   - token: Токен текущего пользователя.
    ///   - completion: Замыкание, в которое возвращается пост, которому был поставлен лайк.
    ///   Вызывается после выполнения запроса.
    func likePost(withID postID: String,
                  token: String,
                  completion: @escaping (Post?) -> Void) {
        
        guard let url = urlService
                .getURL(forPath: PostPath.like) else { return }
        
        var request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.post,
                                             token: token)
        
        let postIDRequest = PostIDRequest(postID: postID)
        
        request.httpBody = try? JSONEncoder().encode(postIDRequest)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Удаляет лайк от текущего пользователя на публикации с запрошенным ID.
    /// - Parameters:
    ///   - postID: ID поста.
    ///   - token: Токен текущего пользователя.
    ///   - completion: Замыкание, в которое возвращается пост, которому был поставлен анлайк.
    ///   Вызывается после выполнения запроса.
    func unlikePost(withID postID: String,
                    token: String,
                    completion: @escaping (Post?) -> Void) {
        
        guard let url = urlService
                .getURL(forPath: PostPath.unlike) else { return }
        
        var request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.post,
                                             token: token)
        
        let postIDRequest = PostIDRequest(postID: postID)
        
        request.httpBody = try? JSONEncoder().encode(postIDRequest)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    /// Получение пользователей, поставивших лайк на публикацию с переданным ID.
    /// - Parameters:
    ///   - postID: ID поста.
    ///   - token: Токен текущего пользователя.
    ///   - completion: Замыкание, в которое возвращаются запрашиваемые пользователи.
    ///   Вызывается после выполнения запроса.
    func getUsersLikedPost(withID postID: String,
                           token: String,
                           completion: @escaping ([User]?) -> Void) {
        
        guard let url = urlService.getURL(forPath: PostPath.posts + postID + PostPath.likes) else { return }
        
        let request = requestService.request(url: url,
                                             httpMethod: HTTPMethod.get,
                                             token: token)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    func getImage(fromURL url: URL) -> UIImage? {
        guard let imageData = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: imageData)
    }
}
