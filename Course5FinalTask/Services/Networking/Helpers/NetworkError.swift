//
//  NetworkError.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 12.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

enum NetworkError: Int, Error, LocalizedError {
    case badRequest = 400
    case unauthorized = 401
    case notFound = 404
    case notAcceptable = 406
    case unprocessable = 422
    case transferError = 0
    
    var errorDescription: String? {
        switch self {
        case .badRequest:
            return "Bad request".localized()
        case .unauthorized:
            return "Unauthorized".localized()
        case .notFound:
            return "Not found".localized()
        case .notAcceptable:
            return "Not acceptable".localized()
        case .unprocessable:
            return "Unprocessable".localized()
        case .transferError:
            return "Transfer error".localized()
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
