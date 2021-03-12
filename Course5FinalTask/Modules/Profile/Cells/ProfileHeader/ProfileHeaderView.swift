//
//  ProfileHeader.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 08.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class ProfileHeaderView: UICollectionReusableView {
    
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
        
    // MARK: - Setup UI
    
    private func setupUI() {
        followButton.layer.cornerRadius = UIConstants.buttonsCornerRadius
        avatarImageView.layer.cornerRadius = avatarImageView.halfWidthCornerRadius()
        
        guard let viewModel = viewModel else { return }
        
        // Если это не профиль текущего пользователя, то кнопка подписки/отписки становится видимой
        followButton.isHidden = viewModel.isHiddenFollowButton
    }
    
    // MARK: - Actions
    
    @IBAction private func followButtonTapped() {
        viewModel?.followButtonDidTapped()
    }
    
    @IBAction private func followersButtonTapped() {
        viewModel?.followersButtonTapped()
    }

    @IBAction private func followingsButtonTapped() {
        viewModel?.followingsButtonTapped()
    }
    
    // MARK: - Private methods
    
    private func setupViewModelBindings() {
        viewModel?.user.bind { [unowned self, unowned viewModel = self.viewModel!] _ in
            self.avatarImageView.image = UIImage(data: viewModel.avatarImageData)
            self.fullNameLabel.text = viewModel.userFullName
            self.followButton.setTitle(viewModel.followButtonTitle, for: .normal)
            self.followersButton.setTitle(viewModel.followersButtonTitle, for: .normal)
            self.followingsButton.setTitle(viewModel.followingsButtonTitle, for: .normal)
        }
    }
}
