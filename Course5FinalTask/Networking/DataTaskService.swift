//
//  DataTaskService.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 05.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

protocol DataTaskServiceProtocol {
    func dataTask<T: Decodable>(request: URLRequest,
                                completion: @escaping (Result<T, Error>) -> Void)
}

final class DataTaskService: DataTaskServiceProtocol {
    
    static let shared = DataTaskService()

    private init() {}
    
    func dataTask<T: Decodable>(request: URLRequest,
                                completion: @escaping (Result<T, Error>) -> Void) {
                
        URLSession.shared.dataTask(with: request) {
            [weak self] (data, response, error) in
            
            guard let self = self else { return }
            
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data else {
                print("Receive HTTP response error")
                return
            }
            
            guard self.handleServerError(httpResponse,
                                         completion: completion) else { return }
            print(httpResponse.statusCode, request.url?.path ?? "")
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.serverDateFormatter)
            
            do {
                let result = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                if !data.isEmpty {
                    print(error.localizedDescription)
                }
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Обработка ошибок сервера, по статус-коду в response.
    /// - Parameters:
    ///   - response: Ответ от сервера.
    ///   - completion: Замыкание, в которое возвращается ошибка от сервера. Вызывается, если в ответе от сервера статус-код не равен 200.
    /// - Returns: Возвращает true если в ответ от сервера пришёл статус-код 200, в иных случаях возвращает false.
    private func handleServerError<T>(_ response: HTTPURLResponse,
                                      completion: (Result<T, Error>) -> Void) -> Bool {
        
        if response.statusCode == 200 {
            return true
        } else {
            let serverError: ServerError
            
            switch response.statusCode {
            case 400: serverError = .badRequest
            case 401: serverError = .unauthorized
            case 404: serverError = .notFound
            case 406: serverError = .notAcceptable
            case 422: serverError = .unprocessable
            default: serverError = .transferError
            }
            completion(.failure(serverError))
            return false
        }
    }
}
