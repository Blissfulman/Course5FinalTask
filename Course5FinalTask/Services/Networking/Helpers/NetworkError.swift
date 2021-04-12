//
//  NetworkError.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 12.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

enum NetworkError: Int, Error {
    case badRequest = 400
    case unauthorized = 401
    case notFound = 404
    case notAcceptable = 406
    case unprocessable = 422
    case transferError = 0
    
    var localizedDescription: String {
        switch self {
        case .badRequest:
            return "Bad request"
        case .unauthorized:
            return "Unauthorized"
        case .notFound:
            return "Not found"
        case .notAcceptable:
            return "Not acceptable"
        case .unprocessable:
            return "Unprocessable"
        case .transferError:
            return "Transfer error"
        }
    }
    
    init?(statusCode: Int) {
        switch statusCode {
        case 400...499:
            guard let networkError = NetworkError(rawValue: statusCode) else {
                self = NetworkError.transferError
                return
            }
            self = networkError
        default:
            return nil
        }
    }
}
