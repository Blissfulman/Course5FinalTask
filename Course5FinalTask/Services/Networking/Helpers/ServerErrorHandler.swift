//
//  ServerErrorHandler.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 28.03.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

final class ServerErrorHandler {
    
    /// Проверка наличия ошибки по статус-коду ответа от сервера.
    /// - Parameters:
    ///   - statusCode: Статус-код ответа от сервера.
    ///   - completion: Замыкание, в которое возвращается ошибка сервера. Вызывается, если статус-код является кодом ошибки.
    /// - Returns: Возвращает false если статус-код равен 200, в остальных случаях возвращает true.
    static func checkError<T>(_ statusCode: Int, completion: (Result<T, Error>) -> Void) -> Bool {
        guard statusCode != 200 else { return false }
        
        if let serverError = ServerError.init(statusCode: statusCode) {
            completion(.failure(serverError))
        }
        return true
    }
}
