//
//  FeedPostCell.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 04.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class FeedPostCell: UITableViewCell {
    
    // MARK: - Nested types
    
    enum LikeColor {
        static let like = UIColor.systemBlue
        static let unlike = UIColor.lightGray
    }
    
    // MARK: - Outlets
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var authorUsernameLabel: UILabel!
    @IBOutlet private weak var createdTimeLabel: UILabel!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var bigLikeImageView: UIImageView!
    @IBOutlet private weak var likesCountButton: UIButton!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    // MARK: - Properties
    
    var viewModel: FeedPostCellViewModelProtocol?
        
    // MARK: - Lifeсycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.setHalfHeightCornerRadius()
        setupGestureRecognizers()
    }
    
    // MARK: - Public methods
    
    func configure() {
        guard let viewModel = viewModel else { return }
        
        avatarImageView.image = UIImage(data: viewModel.avatarImageData)
        authorUsernameLabel.text = viewModel.authorUsername
        createdTimeLabel.text = viewModel.createdTime
        postImageView.image = UIImage(data: viewModel.postImageData)
        descriptionLabel.text = viewModel.description
        likesCountButton.setTitle(viewModel.likesCountButtonTitle, for: .normal)
        likeButton.tintColor = viewModel.currentUserLikesThisPost ? LikeColor.like : LikeColor.unlike
        
        setupViewModelBindings()
    }
    
    // MARK: - Actions
    
    @objc private func postAuthorTapped() {
        viewModel?.postAuthorTapped()
    }
    
    @objc private func postImageDoubleTapped() {
        viewModel?.postImageDoubleTapped()
    }
    
    @IBAction private func likesCountButtonTapped() {
        viewModel?.likesCountButtonTapped()
    }
    
    @IBAction private func likeButtonTapped() {
        viewModel?.likeUnlikePost()
    }
    
    // MARK: - Private methods
    
    private func setupGestureRecognizers() {
        
        // Жест двойного тапа по картинке поста
        let postImageGR = UITapGestureRecognizer(
            target: self, action: #selector(postImageDoubleTapped)
        )
        postImageGR.numberOfTapsRequired = 2
        postImageView.addGestureRecognizer(postImageGR)
        
        // Жест тапа по автору поста (по аватарке)
        let authorAvatarGR = UITapGestureRecognizer(
            target: self, action: #selector(postAuthorTapped)
        )
        avatarImageView.addGestureRecognizer(authorAvatarGR)
        
        // Жест тапа по автору поста (по username)
        let authorUsernameGR = UITapGestureRecognizer(
            target: self, action: #selector(postAuthorTapped)
        )
        authorUsernameLabel.addGestureRecognizer(authorUsernameGR)
    }
    
    private func setupViewModelBindings() {
        viewModel?.likeDataNeedUpdating = { [unowned self] in
            likesCountButton.setTitle(viewModel?.likesCountButtonTitle, for: .normal)
            UIView.animate(withDuration: 0.3) {
                likeButton.tintColor = viewModel?.currentUserLikesThisPost ?? false
                    ? LikeColor.like
                    : LikeColor.unlike
            }
        }

        viewModel?.bigLikeNeedAnimating = { [unowned self] in
            bigLikeImageView.bigLikeAnimation()
        }
    }
}
