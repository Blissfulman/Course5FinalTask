//
//  ShareViewController.swift
//  Course4FinalTask
//
//  Created by User on 08.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

protocol ShareViewControllerDelegate: UIViewController {
    func updateAfterPosting()
}

final class ShareViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet weak var shareImage: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    // MARK: - Properties
    weak var delegate: ShareViewControllerDelegate?
    
    /// Переданное изображение для публикации.
    private lazy var transmittedImage = UIImage()
    
    private let networkService: NetworkServiceProtocol = NetworkService.shared
    
    // MARK: - Initializers
    convenience init(transmittedImage: UIImage) {
        self.init()
        self.transmittedImage = transmittedImage
    }
    
    // MARK: - Lifeсycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Setup UI
    func setupUI() {
        shareImage.image = transmittedImage
        
        let shareButton = UIBarButtonItem(title: "Share",
                                          style: .plain,
                                          target: self,
                                          action: #selector(shareButtonPressed))
        navigationItem.rightBarButtonItem = shareButton
    }
    
    // MARK: - Actions
    @objc func shareButtonPressed() {
        
        guard let description = descriptionTextField.text else { return }

        // Публикация нового поста
        networkService.createPost(image: transmittedImage, description: description) {
            [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success:
                // Получение корневого вью элемента таб бара "Feed"
                guard let navControllerFeed = self.tabBarController?.viewControllers?.first
                        as? UINavigationController else { return }
                navControllerFeed.popToRootViewController(animated: true)
                
                // Переход в ленту
                self.tabBarController?.selectedIndex = 0
                
                // Вызов метода для прокрутки ленты в верхнее положение
                guard let feedVC = navControllerFeed.viewControllers.first
                        as? FeedViewController else { return }
                self.delegate = feedVC
                self.delegate?.updateAfterPosting()
                
                // Переход на корневое вью элемента таб бара "New post"
                self.navigationController?.popToRootViewController(animated: false)
            case let .failure(error):
                self.showAlert(error)
            }
        }
    }
}
