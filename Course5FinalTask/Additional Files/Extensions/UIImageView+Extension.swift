//
//  UIImageView+Extension.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 17.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Kingfisher

extension UIImageView {
    
    func getImage(fromURL url: URL) {
        kf.indicatorType = .activity
        kf.setImage(with: url)
    }
}
