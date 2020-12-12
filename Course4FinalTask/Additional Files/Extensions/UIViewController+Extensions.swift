//
//  UIViewController+Extensions.swift
//  Course4FinalTask
//
//  Created by User on 17.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(_ error: Error?) {
        var alertTitle = "Unknown error!"
        var alertMessage = "Please, try again later"
        
        if let error = error as? ServerError {
            alertTitle = "Error"
            alertMessage = error.rawValue
        }
        
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: alertTitle,
                                          message: alertMessage,
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(okAction)
            self?.present(alert, animated: true)
            LoadingView.hide()
        }
    }
}
