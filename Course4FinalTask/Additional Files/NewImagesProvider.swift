//
//  NewImagesProvider.swift
//  Course4FinalTask
//
//  Created by User on 17.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

protocol NewImagesProviderProtocol {
    func getNewImages() -> [UIImage]
}

final class NewImagesProvider: NewImagesProviderProtocol {
    
    static let shared = NewImagesProvider()
    
    private init() {}
    
    /// Получение изображений для использования в новых публикациях.
    func getNewImages() -> [UIImage] {
        
        var newImages = [UIImage]()
        
        // !!! Временно захардкоженное значение количества новых изображений !!!
        let newImagesCount = 8
        
        for index in 1...newImagesCount {
            if let image = UIImage(named: "new\(index)") {
                newImages.append(image)
            }
        }
        return newImages
    }
}
