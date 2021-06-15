//
//  KeychainService.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 06.03.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

// MARK: - Protocols

protocol KeychainServiceProtocol {
    func getToken() -> TokenModel?
    @discardableResult func saveToken(_ token: TokenModel) -> Bool
    @discardableResult func removeToken() -> Bool
}

final class KeychainService: KeychainServiceProtocol {
    
    // MARK: - Properties
    
    private let serviceName = "Course5FinalTask"
    
    // MARK: - Public methods
    
    func getToken() -> TokenModel? {
        guard let token = readToken() else {
            print("No keychain data")
            return nil
        }
        return TokenModel(token: token)
    }
    
    func saveToken(_ token: TokenModel) -> Bool {
        let tokenData = token.token.data(using: .utf8)
        
        if readToken() != nil {
            var attributesToUpdate = [String: AnyObject]()
            attributesToUpdate[kSecValueData as String] = tokenData as AnyObject
            
            let query = keychainQuery()
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            return status == noErr
        }
        
        var item = keychainQuery()
        item[kSecValueData as String] = tokenData as AnyObject
        let status = SecItemAdd(item as CFDictionary, nil)
        
        if status == noErr {
            print("Token saved")
        }
        return status == noErr
    }
    
    func removeToken() -> Bool {
        print("Removing keychain data")
        let item = keychainQuery()
        let status = SecItemDelete(item as CFDictionary)
        return status == noErr
    }
    
    // MARK: - Private methods
    
    private func keychainQuery() -> [String: AnyObject] {
        let query = [kSecClass as String: kSecClassGenericPassword,
                     kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
                     kSecAttrService as String: serviceName as AnyObject]
        return query
    }

    private func readToken() -> String? {
        var query = keychainQuery()
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        
        var queryResult: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &queryResult)
        
        guard status == noErr else { return nil }
        
        guard let item = queryResult as? [String: AnyObject],
              let tokenData = item[kSecValueData as String] as? Data,
              let token = String(data: tokenData, encoding: .utf8) else {
            print("Unexpected token data")
            return nil
        }
        return token
    }
}
