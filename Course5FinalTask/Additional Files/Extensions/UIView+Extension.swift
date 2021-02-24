//
//  UIView+Extension.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 21.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit

extension UIView {
    
    /// Возвращает радиус скругления, равный половине ширины вью.
    func halfWidthCornerRadius() -> CGFloat {
        self.frame.width / 2
    }
    
    /// Анимация лайка при двойном тапе по изображению поста в ленте.
    func bigLikeAnimation() {
        let likeAnimation = CAKeyframeAnimation(keyPath: "opacity")
        likeAnimation.values = [0, 1, 1, 0]
        likeAnimation.keyTimes = [0, 0.1, 0.3, 0.6]
        likeAnimation.timingFunctions = [.init(name: .linear),
                                         .init(name: .linear),
                                         .init(name: .easeOut)]
        likeAnimation.duration = 0.6
        layer.add(likeAnimation, forKey: nil)
    }
}
