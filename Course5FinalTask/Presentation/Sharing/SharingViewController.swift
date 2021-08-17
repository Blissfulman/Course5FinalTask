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
    
    // MARK: - Initialization
    
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
            title: "Share".localized(),
            style: .plain,
            target: self,
            action: #selector(shareButtonTapped)
        )
        navigationItem.rightBarButtonItem = shareButton
    }
    
    // MARK: - Actions
    
    @objc private func shareButtonTapped() {
        viewModel.createPost(withDescription: descriptionTextField.text)
    }
    
    // MARK: - Navigation
    
    private func transitionToFeed() {
        guard let feedNC = tabBarController?.viewControllers?.first as? UINavigationController else { return }
        feedNC.popToRootViewController(animated: true)
        
        tabBarController?.selectedIndex = 0
        
        // Вызов метода, который выполнит прокрутку ленты в верхнее положение
        if let feedVC = feedNC.viewControllers.first as? SharingViewControllerDelegate {
            feedVC.updateAfterPosting()
        }
    }
    
    // MARK: - Private methods
    
    private func setupViewModelBindings() {
        viewModel.postDidCreateSuccessfully = { [unowned self] in
            transitionToFeed()
            
            // Переход на корневое вью элемента таб бара "New post"
            navigationController?.popToRootViewController(animated: false)
        }
        
        viewModel.error.bind { [unowned self] error in
            guard let error = error else { return }
            showAlert(error)
        }
    }
}
