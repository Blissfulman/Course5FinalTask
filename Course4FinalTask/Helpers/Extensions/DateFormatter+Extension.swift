//
//  DateFormatter+Extension.swift
//  Course4FinalTask
//
//  Created by User on 02.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let postDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
//        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        return dateFormatter
    }()
}
