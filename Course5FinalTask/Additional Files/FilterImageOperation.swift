//
//  FilterImageOperation.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 07.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class FilterImageOperation: Operation {
    
    private var inputImage: Data
    private(set) var outputImage: Data?
    private var filterName: String
    
    init(inputImage: Data, filter: String) {
        self.filterName = filter
        self.inputImage = inputImage
    }
    
    override func main() {
        let context = CIContext()
        let coreImage = CIImage(data: inputImage)
        
        // Создание фильтра
        guard let filter = CIFilter(name: filterName) else { return }
        filter.setValue(coreImage, forKey: kCIInputImageKey)
        
        // Добавление фильтра к изображению
        guard let filteredImage = filter.outputImage else { return }
        
        // Применение фильтра
        guard let cgImage = context.createCGImage(filteredImage,
                                                  from: filteredImage.extent) else { return }
        
        outputImage = UIImage(cgImage: cgImage).pngData()
    }
}
