//
//  NetworkErrorHandler.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 28.03.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

final class NetworkErrorHandler {
    
    /// Проверка наличия NetworkError ошибки по статус-коду ответа от сервера.
    /// - Parameters:
    ///   - statusCode: Статус-код ответа от сервера.
    ///   - completion: Замыкание, в которое возвращается обнаруженная ошибка. Вызывается, если статус-код соответствует NetworkError.
    /// - Returns: Возвращает false если статус-код равен 200, в остальных случаях возвращает true.
    static func checkNetworkError<T>(_ statusCode: Int, completion: (Result<T, Error>) -> Void) -> Bool {
        guard statusCode != 200 else { return false }
        
        if let networkError = NetworkError.init(statusCode: statusCode) {
            completion(.failure(networkError))
        }
        return true
    }
}
