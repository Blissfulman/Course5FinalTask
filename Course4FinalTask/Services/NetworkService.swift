//
//  NetworkService.swift
//  Course4FinalTask
//
//  Created by User on 01.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import UIKit

protocol NetworkServiceProtocol {
    func singIn(login: String,
                password: String,
                completion: @escaping (Token?) -> Void)
    func feed(token: String, completion: @escaping ([Post]?) -> Void)
    func getImage(fromURL url: URL) -> UIImage?
}

final class NetworkService: NetworkServiceProtocol {
    
    func singIn(login: String,
                password: String,
                completion: @escaping (Token?) -> Void) {
        
        guard let url = URLService().getURL(forPath: TokenPath.signIn) else { return }
        
        var request = RequestService().request(url: url, httpMethod: HTTPMethod.post)
        
        let authorization = Authorization(login: login, password: password)
        
        request.httpBody = try? JSONEncoder().encode(authorization)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse, let data = data {
                
                if response.statusCode == 422 {
                    print("Wrong login or password")
                }
                
                guard let token = Token.getFromJSON(data) else { return }
                
                completion(token)
            }
        }.resume()
    }
    
    func feed(token: String, completion: @escaping ([Post]?) -> Void) {
        
        guard let url = URLService().getURL(forPath: PostPath.feed) else { return }
        
        let request = RequestService().request(url: url,
                                               httpMethod: HTTPMethod.get,
                                               token: token)
        
        print(request)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse, let data = data {
                
                print(response.statusCode)
                if let string = String(data: data, encoding: .utf8) {
                    print(string)
                }
                     
//                var posts = [Post]()
                
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data, options: [])
//
//                    guard let postsData = json as? [Any] else { return }
//                    postsData.forEach { posts.append(Post(from: $0)) }
//                } catch {
//                    print(error.localizedDescription)
//                }
                
                do {
                    let posts = try JSONDecoder().decode([Post].self, from: data)
                    completion(posts)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    func getImage(fromURL url: URL) -> UIImage? {
        guard let imageData = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: imageData)
    }
}
