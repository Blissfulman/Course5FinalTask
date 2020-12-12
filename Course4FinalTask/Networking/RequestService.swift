//
//  RequestService.swift
//  Course4FinalTask
//
//  Created by User on 01.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

protocol RequestServiceProtocol {
    func request(url: URL, httpMethod: String, token: String?) -> URLRequest
}

final class RequestService: RequestServiceProtocol {

    func request(url: URL, httpMethod: String, token: String?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token ?? "", forHTTPHeaderField: "token")
        return request
    }
}
