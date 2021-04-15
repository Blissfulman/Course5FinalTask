//
//  DataTaskService.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 05.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

// MARK: - Protocols

protocol DataTaskServiceProtocol {
    func simpleDataTask(request: URLRequest, completion: @escaping VoidResult)
    func dataTask<T: Decodable>(request: URLRequest,
                                completion: @escaping (Result<T, Error>) -> Void)
}

final class DataTaskService: DataTaskServiceProtocol {
    
    // MARK: - Public methods
    
    func simpleDataTask(request: URLRequest, completion: @escaping VoidResult) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                assertionFailure("Receive HTTP response error")
                return
            }
            
            guard !NetworkErrorHandler.checkNetworkError(httpResponse.statusCode,
                                                         completion: completion) else { return }
            
            print(httpResponse.statusCode, request.url?.path ?? "")
            completion(.success(()))
        }.resume()
    }
    
    func dataTask<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                assertionFailure("Receive HTTP response error")
                return
            }
            
            guard !NetworkErrorHandler.checkNetworkError(httpResponse.statusCode,
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
}
