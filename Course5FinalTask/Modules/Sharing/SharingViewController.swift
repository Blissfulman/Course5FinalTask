//
//  SharingViewController.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 08.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

// MARK: - Protocols

protocol SharingViewControllerDelegate: UIViewController {
    func updateAfterPosting()
}

final class SharingViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var descriptionTextField: UITextField!
    
    // MARK: - Properties
    
    var viewModel: SharingViewModelProtocol
    weak var delegate: SharingViewControllerDelegate?
    
    // MARK: - Initializers
    
    init(viewModel: SharingViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifeсycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupViewModelBindings()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        imageView.image = UIImage(data: viewModel.imageData)
        
        let shareButton = UIBarButtonItem(
            title: "Share", style: .plain, target: self, action: #selector(shareButtonTapped)
        )
        navigationItem.rightBarButtonItem = shareButton
    }
    
    // MARK: - Actions
    
    @objc private func shareButtonTapped() {
        viewModel.createPost(withDescription: descriptionTextField.text)
    }
    
    // MARK: - Private methods
    
    private func setupViewModelBindings() {
        viewModel.postDidCreateSuccessfully = {
            // Получение корневого вью элемента таб бара "Feed"
            guard let navControllerFeed = self.tabBarController?.viewControllers?.first
                    as? UINavigationController else { return }
            navControllerFeed.popToRootViewController(animated: true)
            
            // Переход в ленту
            self.tabBarController?.selectedIndex = 0
            
            // Вызов метода, который выполнит прокрутку ленты в верхнее положение
            guard let feedVC = navControllerFeed.viewControllers.first
                    as? FeedViewController else { return }
            self.delegate = feedVC
            self.delegate?.updateAfterPosting()
            
            // Переход на корневое вью элемента таб бара "New post"
            self.navigationController?.popToRootViewController(animated: false)
        }
        
        viewModel.error.bind { [weak self] error in
            guard let error = error else { return }
            self?.showAlert(error)
        }
    }
}
