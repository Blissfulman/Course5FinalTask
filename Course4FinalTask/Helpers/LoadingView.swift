//
//  LoadingView.swift
//  Course4FinalTask
//
//  Created by User on 05.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

/// Вью с индикатором активности, отображаемое во время загрузки данных.
final class LoadingView {
        
    static var activityIndicator: UIActivityIndicatorView?
    
    static let application = UIApplication.shared
    
    static private func create() {
        guard let window = application.windows.first(where: { $0.isKeyWindow }) else { return }
        let frame = UIScreen.main.bounds
        activityIndicator = UIActivityIndicatorView(frame: frame)
        
        activityIndicator?.backgroundColor = UIColor(white: 0, alpha: 0.7)
        activityIndicator?.color = .white
        activityIndicator?.style = .medium
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.isHidden = true
        guard let activityIndicator = activityIndicator else { return }
        window.addSubview(activityIndicator)
    }
    
    static func show() {
        DispatchQueue.main.async {
            create()
            activityIndicator?.startAnimating()
            activityIndicator?.isHidden = false
        }
    }
    
    static func hide() {
        DispatchQueue.main.async {
            activityIndicator?.stopAnimating()
//            activityIndicator?.removeFromSuperview()
//            activityIndicator = nil
        }
    }
}
