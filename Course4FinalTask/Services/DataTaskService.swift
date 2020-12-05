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
                              completion: @escaping (T) -> Void)
}

final class DataTaskService: DataTaskServiceProtocol {
    
    func dataTask<T: Codable>(request: URLRequest,
                              completion: @escaping (T) -> Void) {
                
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse, let data = data {
                
                print(response.statusCode, request.url?.path ?? "")
                     
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(result)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
}
