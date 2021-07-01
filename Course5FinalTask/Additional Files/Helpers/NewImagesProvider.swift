//
//  NewImagesProvider.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 17.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

protocol NewImagesProviderProtocol {
    static func getImages() -> [Data]
}

final class NewImagesProvider: NewImagesProviderProtocol {
    
    /// Получение изображений для использования в новых публикациях.
    static func getImages() -> [Data] {
        
        var images = [Data?]()
        
        // !!! Временно захардкоженное значение количества новых изображений !!!
        let newImagesCount = 8
        
        for index in 1...newImagesCount {
            if let image = UIImage(named: "new\(index)") {
                images.append(image.pngData())
            }
        }
        return images.compactMap { $0 }
    }
}
