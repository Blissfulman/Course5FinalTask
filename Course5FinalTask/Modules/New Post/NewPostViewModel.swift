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
}

final class NewPostViewModel: NewPostViewModelProtocol {
    
    // MARK: - Properties
    
    var images = [Data]()
    
    var numberOfItems: Int {
        images.count
    }
    
    // MARK: - Initializers
    
    init() {
        getImages()
    }
    
    // MARK: - Public methods
    
    func getCellData(at indexPath: IndexPath) -> Data {
        images[indexPath.item]
    }
    
    func getFiltersViewModel(at indexPath: IndexPath) -> FiltersViewModelProtocol {
        FiltersViewModel(imageData: images[indexPath.item])
    }
    
    // MARK: - Private methods
    
    private func getImages() {
        images = NewImagesProvider.getImages()
    }
}
