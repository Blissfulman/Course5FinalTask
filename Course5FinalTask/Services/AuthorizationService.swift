//
//  AuthorizationService.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 09.03.2021.
//

import Foundation

typealias VoidResult = (Result<Void, Error>) -> Void
typealias TokenResult = (Result<TokenModel, Error>) -> Void

// MARK: - Protocols

protocol AuthorizationServiceProtocol {
    
    /// Запрос авторизации пользователя и получения токена.
    /// - Parameters:
    ///   - login: Логин пользователя.
    ///   - password: Пароль пользователя.
    ///   - completion: Замыкание, в которое возвращается токен авторизованного пользователя.
    ///   Вызывается после выполнения запроса.
    func singIn(login: String, password: String, completion: @escaping TokenResult)
    
    /// Проверка валидности токена.
    /// - Parameter completion: Замыкание, вызываемое после выполнения запроса.
    func checkToken(completion: @escaping VoidResult)
    
    /// Деавторизация пользователя и инвалидация токена.
    /// - Parameter completion: Замыкание, вызываемое после выполнения запроса.
    func singOut(completion: @escaping VoidResult)
}

final class AuthorizationService: AuthorizationServiceProtocol {
    
    // MARK: - Static properties
    
    static let shared: AuthorizationServiceProtocol = AuthorizationService()
    
    // MARK: - Properties
    
    private var isOnline: Bool {
        NetworkService.isOnline
    }
    
    private let requestService: RequestServiceProtocol = RequestService.shared
    private let dataTaskService: DataTaskServiceProtocol = DataTaskService.shared
    private let offlineMode = AppError.offlineMode
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Public methods
    
    func singIn(login: String, password: String, completion: @escaping TokenResult) {
        guard let url = AuthorizationURLCreator.signIn.url else { return }
        
        var request = requestService.request(url: url, httpMethod: .post)
        
        let authorization = AuthorizationModel(login: login, password: password)
        request.httpBody = try? JSONEncoder().encode(authorization)
        
        dataTaskService.dataTask(request: request, completion: completion)
    }
    
    func checkToken(completion: @escaping VoidResult) {
        guard let url = AuthorizationURLCreator.checkToken.url else { return }
        
        let request = requestService.request(url: url, httpMethod: .get)
        dataTaskService.simpleDataTask(request: request, completion: completion)
    }
    
    func singOut(completion: @escaping VoidResult) {
        if isOnline {
            guard let url = AuthorizationURLCreator.signOut.url else { return }
            
            let request = requestService.request(url: url, httpMethod: .post)
            dataTaskService.simpleDataTask(request: request, completion: completion)
        } else {
            completion(.failure(offlineMode))
        }
    }
}
