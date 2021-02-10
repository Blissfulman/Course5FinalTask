//
//  DateFormatter+Extension.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 02.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    static let serverDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return dateFormatter
    }()
    
    static let postDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()
}
