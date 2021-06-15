//
//  UIView+Extension.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 21.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit

extension UIView {
    
    /// Возвращает половину высоты вью.
    func halfHeight() -> CGFloat {
        frame.height / 2
    }
    
    /// Делает вью круглым, присваивая радиус скругления, равный половине высоты вью.
    func round() {
        layer.cornerRadius = halfHeight()
    }
    
    /// Устанавливает переданный радиус скругления углов.
    /// - Parameter value: Значение радиуса.
    func setCornerRadius(_ value: CGFloat) {
        layer.cornerCurve = .continuous
        layer.cornerRadius = value
        clipsToBounds = true
    }
    
    /// Анимация лайка при двойном тапе по изображению поста в ленте.
    func bigLikeAnimation() {
        let likeAnimation = CAKeyframeAnimation(keyPath: "opacity")
        likeAnimation.values = [0, 1, 1, 0]
        likeAnimation.keyTimes = [0, 0.1, 0.3, 0.6]
        likeAnimation.timingFunctions = [
            .init(name: .linear),
            .init(name: .linear),
            .init(name: .easeOut)
        ]
        likeAnimation.duration = 0.6
        layer.add(likeAnimation, forKey: nil)
    }
}
