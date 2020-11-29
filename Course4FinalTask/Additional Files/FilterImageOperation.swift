//
//  FilterImageOperation.swift
//  Course3FinalTask
//
//  Created by User on 07.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class FilterImageOperation: Operation {
    
    private var inputImage: UIImage
    private(set) var outputImage: UIImage?
    private var chosenFilter: String
    
    init(inputImage: UIImage, filter: String) {
        self.chosenFilter = filter
        self.inputImage = inputImage
    }
    
    override func main() {
        
        // Создание контекста
        let context = CIContext()
        
        // Создание CIImage
        let coreImage = CIImage(image: inputImage)
        
        // Создание фильтра
        guard let filter = CIFilter(name: chosenFilter) else { return }
        filter.setValue(coreImage, forKey: kCIInputImageKey)
        
        // Добавление фильтра к изображению
        guard let filteredImage = filter.outputImage else { return }
        
        // Применение фильтра
        guard let cgImage = context.createCGImage(filteredImage,
                                                  from: filteredImage.extent) else { return }
        
        // Создание итогового UIImage
        outputImage = UIImage(cgImage: cgImage)
    }
}
