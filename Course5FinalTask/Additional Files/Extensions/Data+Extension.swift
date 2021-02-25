//
//  Data+Extension.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 16.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit

extension Data {
    
    func resizeImageFromImageData(to size: CGSize? = CGSize(width: 50, height: 50)) -> Data {
        guard let size = size, let image = UIImage(data: self) else {
            return Data()
        }
        return UIGraphicsImageRenderer(size: size).pngData { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
