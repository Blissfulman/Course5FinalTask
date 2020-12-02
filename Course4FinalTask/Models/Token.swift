//
//  Token.swift
//  Course4FinalTask
//
//  Created by User on 30.11.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

struct Token: Codable {
    let token: String
    
    static func getFromJSON(jsonData: Data) -> Token? {

        guard let token = try? JSONDecoder().decode(Token.self,
                                                    from: jsonData) else {
            return nil
        }
        return token
    }
}
