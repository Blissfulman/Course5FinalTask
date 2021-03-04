//
//  LoadingView.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 05.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

/// Класс, содержащий вью с индикатором активности, отображаемым во время загрузки данных.
final class LoadingView {
    
    static var activityIndicator = UIActivityIndicatorView(frame: UIScreen.main.bounds)
    
    static func show() {
        DispatchQueue.main.async {
            setup()
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        }
    }
    
    static func hide() {
        DispatchQueue.main.async {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
    
    private static func setup() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.7)
        activityIndicator.color = .white
        activityIndicator.style = .medium
        activityIndicator.hidesWhenStopped = true
        
        window.addSubview(activityIndicator)
    }
}
