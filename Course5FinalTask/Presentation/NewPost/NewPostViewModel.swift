//
//  NewPostViewModel.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 17.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

// MARK: - Protocols

protocol NewPostViewModelProtocol {
    var images: [Data] { get }
    var numberOfItems: Int { get }
    
    func getCellData(at indexPath: IndexPath) -> Data
    func getFiltersViewModel(at indexPath: IndexPath) -> FiltersViewModelProtocol
    func getFiltersViewModel(withImageData imageData: Data) -> FiltersViewModelProtocol
}

final class NewPostViewModel: NewPostViewModelProtocol {
    
    // MARK: - Properties
    
    var images = [Data]()
    
    var numberOfItems: Int {
        images.count
    }
    
    // MARK: - Initialization
    
    init() {
        getImages()
    }
    
    // MARK: - Public methods
    
    func getCellData(at indexPath: IndexPath) -> Data {
        images[indexPath.item]
    }
    
    // Получение `FiltersViewModelProtocol` для изображения из коллекции.
    func getFiltersViewModel(at indexPath: IndexPath) -> FiltersViewModelProtocol {
        FiltersViewModel(imageData: images[indexPath.item])
    }
    
    // Получение `FiltersViewModelProtocol` для изображения из галереи.
    func getFiltersViewModel(withImageData imageData: Data) -> FiltersViewModelProtocol {
        FiltersViewModel(imageData: imageData)
    }
    
    // MARK: - Private methods
    
    private func getImages() {
        images = NewImagesProvider.getImages()
    }
}
