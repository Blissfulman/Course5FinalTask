//
//  RequestService.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 01.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

// MARK: - Protocols

protocol RequestServiceProtocol {
    var token: String { get }
    func request(url: URL, httpMethod: HTTPMethod) -> URLRequest
}

final class RequestService: RequestServiceProtocol {
    
    // MARK: - Properties
    
    var token: String {
        keychainService.getToken()?.token ?? ""
    }
    
    private let keychainService: KeychainServiceProtocol = KeychainService()
    
    // MARK: - Public methods
    
    func request(url: URL, httpMethod: HTTPMethod) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "token")
        return request
    }
}
