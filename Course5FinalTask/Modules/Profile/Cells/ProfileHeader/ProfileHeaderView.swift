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
    func followersLabelTapped()
    func followingLabelTapped()
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
    @IBOutlet private weak var followersLabel: UILabel!
    @IBOutlet private weak var followingsLabel: UILabel!
    @IBOutlet private weak var followButton: UIButton!
    
    // MARK: - Properties
    
    var viewModel: ProfileHeaderViewModelProtocol? {
        didSet {
            setupUI()
            setupViewModelBindings()
        }
    }
    
    weak var delegate: ProfileHeaderViewDelegate?
    
    // MARK: - Lifeсycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupGestureRecognizers()
    }
    
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
            self.followersLabel.text = viewModel.followersLabelTitle
            self.followingsLabel.text = viewModel.followingsLabelTitle
            self.followButton.setTitle(viewModel.followButtonTitle, for: .normal)
            self.followersLabel.text = viewModel.followersLabelTitle
        }
        
        viewModel.error.bind { [weak self] error in
            guard let error = error else { return }
            self?.delegate?.showErrorAlert(error)
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func followersLabelTapped() {
        delegate?.followersLabelTapped()
    }
    
    @IBAction private func followingLabelTapped() {
        delegate?.followingLabelTapped()
    }
    
    @IBAction private func followButtonTapped() {
        viewModel?.followButtonDidTapped()
    }
    
    private func setupGestureRecognizers() {
        // Жест тапа по подписчикам
        let followersGR = UITapGestureRecognizer(target: self,
                                                 action: #selector(followersLabelTapped))
        followersLabel.isUserInteractionEnabled = true
        followersLabel.addGestureRecognizer(followersGR)
        
        // Жест тапа по подпискам
        let followingGR = UITapGestureRecognizer(target: self,
                                                 action: #selector(followingLabelTapped))
        followingsLabel.isUserInteractionEnabled = true
        followingsLabel.addGestureRecognizer(followingGR)
    }
}
