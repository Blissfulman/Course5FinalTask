//
//  FiltersViewModel.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 16.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

// MARK: Protocols

protocol FiltersViewModelProtocol {
    var image: Box<Data> { get }
    var thumbnailDidFilter: ((Int) -> Void)? { get set }
    var numberOfItems: Int { get }
    
    init(imageData: Data)
    
    func getCellData(at: IndexPath) -> (thumbnail: Data, filterName: String)
    func applyFilter(at: IndexPath)
}

final class FiltersViewModel: FiltersViewModelProtocol {
    
    // MARK: - Properties
    
    var image = Box(Data())
    
    var thumbnailDidFilter: ((Int) -> Void)?
    
    var numberOfItems: Int {
        filterNames.count
    }
    
    private let originalImage: Data
    
    /// Массив миниатюр изображения.
    private var thumbnails = [Data]()
    
    private let filterNames = [
        "CISpotLight", "CIPixellate", "CIUnsharpMask", "CISepiaTone",
        "CICircularScreen", "CICMYKHalftone", "CIVignetteEffect"
    ]
    
    // MARK: - Initializers
    
    init(imageData: Data) {
        image.value = imageData
        originalImage = imageData
        applyFiltersToThumbnails()
    }
    
    // MARK: - Public methods
    
    func getCellData(at indexPath: IndexPath) -> (thumbnail: Data, filterName: String) {
        (thumbnails[indexPath.row], filterNames[indexPath.row])
    }
    
    func applyFilter(at indexPath: IndexPath) {
        LoadingView.show()
        
        let queue = OperationQueue()
        let filterOperation = FilterImageOperation(inputImage: originalImage,
                                                   filter: filterNames[indexPath.item])
        
        filterOperation.completionBlock = { [weak self] in
            guard let outputImage = filterOperation.outputImage else { return }
            
            self?.image.value = outputImage
            LoadingView.hide()
        }
        queue.addOperation(filterOperation)
    }
    
    // MARK: - Private methods
    
    private func applyFiltersToThumbnails() {
        let thumbnail = originalImage.resizeImageFromImageData()
        thumbnails = .init(repeating: thumbnail, count: numberOfItems)
        
        let queue = OperationQueue()
        
        for item in 0..<numberOfItems {
            let filterOperation = FilterImageOperation(inputImage: thumbnail,
                                                       filter: filterNames[item])
            
            filterOperation.completionBlock = { [weak self] in
                guard let outputImage = filterOperation.outputImage else { return }
                self?.thumbnails[item] = outputImage
                self?.thumbnailDidFilter?(item)
            }
            queue.addOperation(filterOperation)
        }
    }
}
