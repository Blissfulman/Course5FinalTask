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
    
    // MARK: - Static properties
    
    private static var backView: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .clear
        view.addSubview(activityIndicator)
        return view
    }()
    
    private static var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        activityIndicator.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        activityIndicator.style = .large
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.3)
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        activityIndicator.setCornerRadius(25)
        return activityIndicator
    }()
    
    // MARK: - Static methods
    
    static func show() {
        // Т.к. в оффлайн режиме отображать блокирующее вью не требуется, выполняется проверка данного статуса
        if NetworkService.isOnline {
            DispatchQueue.main.async {
                setup()
                activityIndicator.startAnimating()
            }
        }
    }
    
    static func hide() {
        // Скрывать блокирующее вью в оффлайн режиме также не потребуется
        if NetworkService.isOnline {
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
                backView.removeFromSuperview()
            }
        }
    }
    
    private static func setup() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        window.addSubview(backView)
    }
}
