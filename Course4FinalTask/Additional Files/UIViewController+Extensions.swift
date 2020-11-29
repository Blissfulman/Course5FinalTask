//
//  UIViewController+Extensions.swift
//  Course3FinalTask
//
//  Created by User on 17.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Ok", style: .default))
        present(alert, animated: true)
    }
}
