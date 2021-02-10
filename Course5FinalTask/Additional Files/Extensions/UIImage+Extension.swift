//
//  UIImage+Extension.swift
//  Course5FinalTask
//
//  Created by User on 16.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resizeImage(to size: CGSize? = CGSize(width: 50, height: 50)) -> UIImage {
        guard let size = size else {
            return UIImage()
        }
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func encodeToBase64() -> String {
        guard let imageData = self.jpegData(compressionQuality: 1)?.base64EncodedString() else {
            return ""
        }
        return imageData
    }
}
