//
//  URLService.swift
//  Course5FinalTask
//
//  Created by User on 01.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

protocol URLServiceProtocol {
    func getURL(forPath path: String) -> URL?
}

final class URLService: URLServiceProtocol {

    static let shared = URLService()
    
    private let scheme = "http"
    private let host = "localhost"
    private let port = 8080

    private init() {}
    
    func getURL(forPath path: String) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = path
        
        return urlComponents.url
    }
}
