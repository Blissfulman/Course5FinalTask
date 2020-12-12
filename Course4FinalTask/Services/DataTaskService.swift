//
//  DataTaskService.swift
//  Course4FinalTask
//
//  Created by User on 05.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

protocol DataTaskServiceProtocol {
    func dataTask<T: Codable>(request: URLRequest,
                              completion: @escaping (Result<T, Error>) -> Void)
}

final class DataTaskService: DataTaskServiceProtocol {
    
    func dataTask<T: Codable>(request: URLRequest,
                              completion: @escaping (Result<T, Error>) -> Void) {
                
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse, let data = data {
                
                print(response.statusCode, request.url?.path ?? "")
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.serverDateFormatter)
                     
                do {
                    let result = try decoder.decode(T.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
