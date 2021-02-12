//
//  HeaderProfileCollectionView.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 08.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

// MARK: - Protocols

protocol HeaderProfileCollectionViewDelegate: UIViewController {
    func followersLabelPressed()
    func followingLabelPressed()
    func followUnfollowUser()
}

final class HeaderProfileCollectionView: UICollectionReusableView {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var avatarImage: UIImageView!
    @IBOutlet private weak var fullNameLabel: UILabel!
    @IBOutlet private weak var followersLabel: UILabel!
    @IBOutlet private weak var followingLabel: UILabel!
    @IBOutlet private weak var followButton: UIButton!
    
    // MARK: - Class properties
    
    static let identifier = "headerProfile"
    
    // MARK: - Class methods
    
    static func nib() -> UINib {
        UINib(nibName: "HeaderProfileCollectionView", bundle: nil)
    }
    
    // MARK: - Properties
    
    weak var delegate: HeaderProfileCollectionViewDelegate?
    
    // MARK: - Lifeсycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        followButton.layer.cornerRadius = 5
        setupGestureRecognizers()
    }
    
    // MARK: - Actions
    
    @IBAction func followersLabelPressed(recognizer: UIGestureRecognizer) {
        delegate?.followersLabelPressed()
    }
    
    @IBAction func followingLabelPressed(recognizer: UIGestureRecognizer) {
        delegate?.followingLabelPressed()
    }
    
    @IBAction func followButtonPressed(_ sender: UIButton) {
        delegate?.followUnfollowUser()
    }
    
    // MARK: - Public methods
    
    func configure(user: UserModel, isCurrentUser: Bool) {
        
        // Если это не профиль текущего пользователя, то устанавливается кнопка подписки/отписки
        if !isCurrentUser {
            setupFollowButton(user: user)
            followButton.isHidden = false
        }

        avatarImage.getImage(fromURL: user.avatar)
        avatarImage.layer.cornerRadius = CGFloat(avatarImage.bounds.width / 2)
        fullNameLabel.text = user.fullName
        followersLabel.text = "Followers: " + String(user.followedByCount)
        followingLabel.text = "Following: " + String(user.followsCount)
    }
    
    // MARK: - Private methods
    
    private func setupFollowButton(user: UserModel) {
        user.currentUserFollowsThisUser
            ? followButton.setTitle("Unfollow", for: .normal)
            : followButton.setTitle("Follow", for: .normal)
    }
    
    private func setupGestureRecognizers() {
        
        // Жест тапа по подписчикам
        let followersGR = UITapGestureRecognizer(
            target: self, action: #selector(followersLabelPressed(recognizer:))
        )
        followersLabel.isUserInteractionEnabled = true
        followersLabel.addGestureRecognizer(followersGR)
        
        // Жест тапа по подпискам
        let followingGR = UITapGestureRecognizer(
            target: self, action: #selector(followingLabelPressed(recognizer:))
        )
        followingLabel.isUserInteractionEnabled = true
        followingLabel.addGestureRecognizer(followingGR)
    }
}
