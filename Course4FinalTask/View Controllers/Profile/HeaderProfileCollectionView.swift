//
//  HeaderProfileCollectionView.swift
//  Course4FinalTask
//
//  Created by User on 08.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

protocol HeaderProfileCollectionViewDelegate: UIViewController {
    func tapFollowersLabel()
    func tapFollowingLabel()
    func followUnfollowUser()
}

class HeaderProfileCollectionView: UICollectionReusableView {
    
    // MARK: - IB Outlets
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    // MARK: - Properties
    static let identifier = "headerProfile"
    
    weak var delegate: HeaderProfileCollectionViewDelegate?
    
    // MARK: - Class methods
    static func nib() -> UINib {
        return UINib(nibName: "HeaderProfileCollectionView", bundle: nil)
    }
    
    // MARK: - Lifeсycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        followButton.layer.cornerRadius = 5
        setupGestureRecognizers()
    }
    
    // MARK: - Setup the cell
    func configure(user: User, isCurrentUser: Bool) {
        
        // Если это не профиль текущего пользователя, то устанавливается кнопка подписки/отписки
        if !isCurrentUser {
            setupFollowButton(user: user)
            followButton.isHidden = false
        }
        
//        avatarImage.image = user.avatar
//        avatarImage.layer.cornerRadius = CGFloat(avatarImage.bounds.width / 2)
//        fullNameLabel.text = user.fullName
//        followersLabel.text = "Followers: " + String(user.followedByCount)
//        followingLabel.text = "Following: " + String(user.followsCount)
    }
    
    private func setupFollowButton(user: User) {
    
//        user.currentUserFollowsThisUser ?
//            followButton.setTitle("Unfollow", for: .normal) :
//            followButton.setTitle("Follow", for: .normal)
    }
    
    // MARK: - Setup gesture recognizers
    private func setupGestureRecognizers() {
        
        // Жест тапа по подписчикам
        let followersGR = UITapGestureRecognizer(target: self, action: #selector(tapFollowersLabel(recognizer:)))
        followersLabel.isUserInteractionEnabled = true
        followersLabel.addGestureRecognizer(followersGR)
        
        // Жест тапа по подпискам
        let followingGR = UITapGestureRecognizer(target: self, action: #selector(tapFollowingLabel(recognizer:)))
        followingLabel.isUserInteractionEnabled = true
        followingLabel.addGestureRecognizer(followingGR)
    }
    
    // MARK: - Actions
    @IBAction func tapFollowersLabel(recognizer: UIGestureRecognizer) {
        delegate?.tapFollowersLabel()
    }
    
    @IBAction func tapFollowingLabel(recognizer: UIGestureRecognizer) {
        delegate?.tapFollowingLabel()
    }
    
    @IBAction func followButtonClick(_ sender: UIButton) {
        delegate?.followUnfollowUser()
    }
}
