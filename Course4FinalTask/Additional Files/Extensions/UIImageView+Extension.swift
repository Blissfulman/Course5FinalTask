//
//  UIImageView+Extension.swift
//  Course4FinalTask
//
//  Created by User on 17.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Kingfisher

extension UIImageView {
    
    func getImage(fromURL url: URL) {
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url)
    }
}
