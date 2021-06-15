//
//  String+Extension.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 15.06.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

extension String {
    
    func localized() -> String {
        NSLocalizedString(self, comment: "")
    }
}
