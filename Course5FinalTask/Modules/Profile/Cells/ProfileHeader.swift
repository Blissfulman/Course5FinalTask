//
//  ProfileHeader.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 08.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

// MARK: - Protocols

protocol ProfileHeaderDelegate: UIViewController {
    func followersLabelTapped()
    func followingLabelTapped()
    func followUnfollowUser()
}

final class ProfileHeader: UICollectionReusableView {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var fullNameLabel: UILabel!
    @IBOutlet private weak var followersLabel: UILabel!
    @IBOutlet private weak var followingLabel: UILabel!
    @IBOutlet private weak var followButton: UIButton!
    
    // MARK: - Class properties
    
    static let identifier = String(describing: ProfileHeader.self)
    
    // MARK: - Class methods
    
    static func nib() -> UINib {
        UINib(nibName: identifier, bundle: nil)
    }
    
    // MARK: - Properties
    
    weak var delegate: ProfileHeaderDelegate?
    
    // MARK: - Lifeсycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        followButton.layer.cornerRadius = UIConstants.buttonsCornerRadius
        setupGestureRecognizers()
    }
    
    // MARK: - Public methods
    
    func configure(user: UserModel, isCurrentUser: Bool) {
        
        // Если это не профиль текущего пользователя, то устанавливается кнопка подписки/отписки
        if !isCurrentUser {
            setupFollowButton(user: user)
            followButton.isHidden = false
        }

        avatarImageView.getImage(fromURL: user.avatar)
        avatarImageView.layer.cornerRadius = CGFloat(avatarImageView.bounds.width / 2)
        fullNameLabel.text = user.fullName
        followersLabel.text = "Followers: " + String(user.followedByCount)
        followingLabel.text = "Following: " + String(user.followsCount)
    }
    
    // MARK: - Actions
    
    @IBAction private func followersLabelTapped() {
        delegate?.followersLabelTapped()
    }
    
    @IBAction private func followingLabelTapped() {
        delegate?.followingLabelTapped()
    }
    
    @IBAction private func followButtonTapped(_ sender: UIButton) {
        delegate?.followUnfollowUser()
    }
    
    // MARK: - Private methods
    
    private func setupFollowButton(user: UserModel) {
        user.currentUserFollowsThisUser
            ? followButton.setTitle("Unfollow", for: .normal)
            : followButton.setTitle("Follow", for: .normal)
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
        followingLabel.isUserInteractionEnabled = true
        followingLabel.addGestureRecognizer(followingGR)
    }
}
