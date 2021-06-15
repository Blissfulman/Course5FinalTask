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
    
    // MARK: - Lifecycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        followButton.setCornerRadius(UIConstants.buttonsCornerRadius)
        avatarImageView.round()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        guard let viewModel = viewModel else { return }
        
        // Если это не профиль текущего пользователя, то кнопка подписки/отписки становится видимой
        followButton.isHidden = viewModel.isHiddenFollowButton
    }
    
    // MARK: - Actions
    
    @IBAction private func followButtonTapped() {
        viewModel?.followButtonTapped()
    }
    
    @IBAction private func followersButtonTapped() {
        viewModel?.followersButtonTapped()
    }
    
    @IBAction private func followingsButtonTapped() {
        viewModel?.followingsButtonTapped()
    }
    
    // MARK: - Private methods
    
    private func setupViewModelBindings() {
        viewModel?.user.bind { [unowned self] _ in
            guard let viewModel = viewModel else { return }
            
            avatarImageView.image = UIImage(data: viewModel.avatarImageData)
            fullNameLabel.text = viewModel.userFullName
            followButton.setTitle(viewModel.followButtonTitle, for: .normal)
            followersButton.setTitle(viewModel.followersButtonTitle, for: .normal)
            followingsButton.setTitle(viewModel.followingsButtonTitle, for: .normal)
        }
    }
}
