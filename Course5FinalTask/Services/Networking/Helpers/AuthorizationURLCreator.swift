//
//  AuthorizationURLCreator.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 11.02.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import  Foundation

enum AuthorizationURLCreator {
    case signIn
    case signOut
    case checkToken
    
    var url: URL? {
        let baseURL = ServerConstants.baseURL
        
        switch self {
        case .signIn:
            return URL(string: baseURL + "signin")
        case .signOut:
            return URL(string: baseURL + "signout")
        case .checkToken:
            return URL(string: baseURL + "checkToken")
        }
    }
}
