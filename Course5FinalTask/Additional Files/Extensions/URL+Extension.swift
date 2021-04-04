//
//  URL+Extension.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 27.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit

extension URL {
    
    /// Возвращает изображение в формате PNG Data, загруженное по URL, либо, случае неудачи, - Data().
    func fetchPNGImageData() -> Data {
        guard let imageData = try? Data(contentsOf: self) else { return Data() }
        guard let pngImageData =  UIImage(data: imageData)?.pngData() else { return Data() }
        return pngImageData
    }
}

extension Optional where Wrapped == URL {
    
    /// Возвращает изображение в формате PNG Data, загруженное по URL, либо, случае неудачи, - Data().
    func fetchPNGImageData() -> Data {
        guard let url = self else { return Data() }
        return url.fetchPNGImageData()
    }
}
