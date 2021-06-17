//
//  AppError.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 11.03.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

enum AppError: Error, LocalizedError {
    case offlineMode
    case noOfflineData
    
    var errorDescription: String? {
        switch self {
        case .offlineMode:
            return "Offline mode".localized()
        case .noOfflineData:
            return "No offline data".localized()
        }
    }
}
