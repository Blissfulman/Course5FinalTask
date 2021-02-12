//
//  ShareViewModel.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 12.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

protocol SharingViewModelProtocol {
    var imageData: Data { get }
    var postDidCreateSuccessfully: (() -> Void)? { get set }
    var error: Box<Error?> { get }
    
    init(imageData: Data)
    
    func createPost(withDescription: String)
}

final class SharingViewModel: SharingViewModelProtocol {
    
    // MARK: - Properties
    
    let imageData: Data
    
    var postDidCreateSuccessfully: (() -> Void)?
    
    var error: Box<Error?> = Box(nil)
    
    private let networkService: NetworkServiceProtocol = NetworkService.shared
    
    init(imageData: Data) {
        self.imageData = imageData
    }
    
    func createPost(withDescription description: String) {
        networkService.createPost(imageData: imageData.base64EncodedString(),
                                  description: description) {
            [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.postDidCreateSuccessfully?()
            case let .failure(error):
                self.error.value = error
            }
        }
    }
}
