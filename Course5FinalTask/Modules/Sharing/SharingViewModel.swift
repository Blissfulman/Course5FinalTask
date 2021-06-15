//
//  SharingViewModel.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 12.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

// MARK: - Protocols

protocol SharingViewModelProtocol {
    var imageData: Data { get }
    var postDidCreateSuccessfully: (() -> Void)? { get set }
    var error: Box<Error?> { get }
    
    init(imageData: Data)
    
    func createPost(withDescription: String?)
}

final class SharingViewModel: SharingViewModelProtocol {
    
    // MARK: - Properties
    
    let imageData: Data
    var postDidCreateSuccessfully: (() -> Void)?
    var error: Box<Error?> = Box(nil)
    
    private let dataFetchingService: DataFetchingServiceProtocol = DataFetchingService.shared
    
    // MARK: - Initializers
    
    init(imageData: Data) {
        self.imageData = imageData
    }
    
    // MARK: - Public methods
    
    func createPost(withDescription description: String?) {
        dataFetchingService.createPost(
            imageData: imageData.base64EncodedString(),
            description: description ?? ""
        ) { [weak self] result in
            
            switch result {
            case .success:
                self?.postDidCreateSuccessfully?()
            case .failure(let error):
                self?.error.value = error
            }
        }
    }
}
