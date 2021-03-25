//
//  AppError.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 11.03.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

enum AppError: Error {
    case offlineMode
    case noOfflineData
    
    var localizedDescription: String {
        switch self {
        case .offlineMode:
            return "Offline mode"
        case .noOfflineData:
            return "No offline data"
        }
    }
}
