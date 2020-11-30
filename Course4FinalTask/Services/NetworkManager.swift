//
//  AuthorizationRequest.swift
//  Course4FinalTask
//
//  Created by User on 30.11.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

struct NetworkManager {
    
    func authorize() {
        let scheme = "http"
        let host = "localhost"
        let port = 8080
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = "/signin"
        
        guard let url = urlComponents.url else { return }
        print(url)
        
        let authorization = Authorization(login: "user", password: "qwerty")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try? JSONEncoder().encode(authorization)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse, let data = data {
                print(response.statusCode)
                print(data)
            }
        }.resume()
    }
}
