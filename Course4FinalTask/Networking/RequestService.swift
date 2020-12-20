//
//  RequestService.swift
//  Course4FinalTask
//
//  Created by User on 01.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

protocol RequestServiceProtocol {
    var token: String { get }
    func request(url: URL, httpMethod: HTTPMethod) -> URLRequest
}

final class RequestService: RequestServiceProtocol {
    
    static let shared = RequestService()
    
    var token: String {
        NetworkService.token
    }
    
    private init() {}
    
    func request(url: URL, httpMethod: HTTPMethod) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "token")
        return request
    }
}
