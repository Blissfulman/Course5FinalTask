//
//  AppError.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 11.03.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

enum AppError: String, Error {
    case offlineError = "Offline mode"
    case noOfflineData = "No offline data"
}
