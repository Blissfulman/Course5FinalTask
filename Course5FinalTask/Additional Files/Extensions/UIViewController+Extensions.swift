//
//  UIViewController+Extensions.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 17.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(_ error: Error?) {
        let isCustomError = (error is NetworkError) || (error is AppError)
        let alertTitle = isCustomError ? error?.localizedDescription : "Unknown error!"
        let alertMessage = isCustomError ? "" : "Please, try again later"
        
        DispatchQueue.main.async { [weak self] in
            LoadingView.hide()
            
            let alert = UIAlertController(title: alertTitle,
                                          message: alertMessage,
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(okAction)
            self?.present(alert, animated: true)
        }
    }
}
