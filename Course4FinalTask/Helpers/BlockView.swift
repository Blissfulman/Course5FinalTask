//
//  BlockView.swift
//  Course4FinalTask
//
//  Created by User on 26.09.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

/// Блокирующее вью с индикатором активности.
class BlockView: UIView {
    
    private var parentView = UIView()
    
    private let activityIndicator = UIActivityIndicatorView()
    
    convenience init(parentView: UIView) {
        self.init()
        self.parentView = parentView
        setup()
    }
    
    func setup() {
        
        // Установка самого вью
        backgroundColor = .black
        alpha = 0.7
        isHidden = true
        translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(self)
                
        let constraints = [
            topAnchor.constraint(equalTo: parentView.topAnchor),
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        // Установка индикатора активности
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    func show() {
        activityIndicator.startAnimating()
        isHidden = false
    }
    
    func hide() {
        isHidden = true
        activityIndicator.stopAnimating()
    }
}
