//
//  ProfileHeader.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 08.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

// MARK: - Protocols

protocol ProfileHeaderViewDelegate: UIViewController {
    func followersButtonTapped()
    func followingButtonTapped()
    func showErrorAlert(_ error: Error)
}

final class ProfileHeaderView: UICollectionReusableView {
    
    // MARK: - Class properties
    
    static let identifier = String(describing: ProfileHeaderView.self)
    
    // MARK: - Class methods
    
    static func nib() -> UINib {
        UINib(nibName: identifier, bundle: nil)
    }
    
    // MARK: - Outlets
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var fullNameLabel: UILabel!
    @IBOutlet private weak var followersButton: UIButton!
    @IBOutlet private weak var followingsButton: UIButton!
    @IBOutlet private weak var followButton: UIButton!
    
    // MARK: - Properties
    
    var viewModel: ProfileHeaderViewModelProtocol? {
        didSet {
            setupUI()
            setupViewModelBindings()
        }
    }
    
    weak var delegate: ProfileHeaderViewDelegate?
    
    // MARK: - Setup UI
    
    private func setupUI() {
        followButton.layer.cornerRadius = UIConstants.buttonsCornerRadius
        avatarImageView.layer.cornerRadius = CGFloat(avatarImageView.bounds.width / 2)
        
        guard let viewModel = viewModel else { return }
        
        // Если это не профиль текущего пользователя, то кнопка подписки/отписки становится видимой
        followButton.isHidden = viewModel.isHiddenFollowButton
    }
    
    // MARK: - Private methods
    
    private func setupViewModelBindings() {
        guard let viewModel = viewModel else { return }
        
        viewModel.user.bind { [weak self] _ in
            guard let self = self else { return }
            
            self.avatarImageView.image = UIImage(data: viewModel.avatarImageData)
            self.fullNameLabel.text = viewModel.userFullName
            self.followersButton.setTitle(viewModel.followersButtonTitle, for: .normal)
            self.followingsButton.setTitle(viewModel.followingsButtonTitle, for: .normal)
            self.followButton.setTitle(viewModel.followButtonTitle, for: .normal)
        }
        
        viewModel.error.bind { [weak self] error in
            guard let error = error else { return }
            self?.delegate?.showErrorAlert(error)
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func followersButtonTapped() {
        delegate?.followersButtonTapped()
    }
    
    @IBAction private func followingButtonTapped() {
        delegate?.followingButtonTapped()
    }
    
    @IBAction private func followButtonTapped() {
        viewModel?.followButtonDidTapped()
    }
}
