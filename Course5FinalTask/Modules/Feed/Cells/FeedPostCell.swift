//
//  FeedPostCell.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 04.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

// MARK: - Protocols

protocol FeedPostCellDelegate: UIViewController {
    func authorOfPostTapped(user: UserModel)
    func likesCountLabelTapped(postID: String)
    func updateFeedData()
    func showErrorAlert(_ error: Error)
}

final class FeedPostCell: UITableViewCell {
    
    // MARK: - Class properties
    
    static let identifier = String(describing: FeedPostCell.self)
    
    // MARK: - Class methods
    
    static func nib() -> UINib {
        UINib(nibName: identifier, bundle: nil)
    }
    
    // MARK: - Outlets
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var authorUsernameLabel: UILabel!
    @IBOutlet private weak var createdTimeLabel: UILabel!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var bigLikeImage: UIImageView!
    @IBOutlet private weak var likesCountButton: UIButton!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    // MARK: - Properties
    
    weak var delegate: FeedPostCellDelegate?
    
    private var cellPost: PostModel! {
        didSet {
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self else { return }
                
                UIView.animate(withDuration: 0.3) {
                    self.likeButton.tintColor = self.cellPost.currentUserLikesThisPost
                        ? .systemBlue
                        : .lightGray
                }
                self.likesCountButton.setTitle("Likes: " + String(self.cellPost.likedByCount),
                                               for: .normal)
            }
        }
    }
    
    private let networkService: NetworkServiceProtocol = NetworkService.shared
    
    // MARK: - Lifeсycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupGestureRecognizers()
    }
    
    // MARK: - Public methods
    
    func configure(_ post: PostModel) {
                
        // Сохранение поста ячейки
        cellPost = post

        // Заполнение всех элементов ячейки данными
        avatarImageView.getImage(fromURL: post.authorAvatar)
        authorUsernameLabel.text = post.authorUsername
        createdTimeLabel.text = DateFormatter.postDateFormatter.string(from: post.createdTime)
        postImageView.getImage(fromURL: post.image)
        descriptionLabel.text = post.description
    }
    
    // MARK: - Working with likes
    
    /// Обработка лайка/анлайка поста.
    private func likeUnlikePost() {

        /// Замыкание, в котором обновляются данные о посте.
        let updatingPost: PostResult = { [weak self] result in
            
            switch result {
            case .success(let updatedPost):
                self?.cellPost = updatedPost
                self?.delegate?.updateFeedData()
            case .failure:
                break
            }
        }
        
        // Лайк/анлайк
        cellPost.currentUserLikesThisPost
            ? networkService.unlikePost(withID: cellPost.id, completion: updatingPost)
            : networkService.likePost(withID: cellPost.id, completion: updatingPost)
    }
}

// MARK: - Setup gesture recognizers

extension FeedPostCell {
    
    private func setupGestureRecognizers() {
        
        // Жест двойного тапа по картинке поста
        let postImageGR = UITapGestureRecognizer(
            target: self, action: #selector(postImageDoubleTapped(recognizer:))
        )
        postImageGR.numberOfTapsRequired = 2
        postImageView.isUserInteractionEnabled = true
        postImageView.addGestureRecognizer(postImageGR)
        
        // Жест тапа по автору поста (по аватарке)
        let authorAvatarGR = UITapGestureRecognizer(
            target: self, action: #selector(postAuthorTapped(recognizer:))
        )
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(authorAvatarGR)
        
        // Жест тапа по автору поста (по username)
        let authorUsernameGR = UITapGestureRecognizer(
            target: self, action: #selector(postAuthorTapped(recognizer:))
        )
        authorUsernameLabel.isUserInteractionEnabled = true
        authorUsernameLabel.addGestureRecognizer(authorUsernameGR)
    }
}

// MARK: - Actions

extension FeedPostCell {
    
    @IBAction private func postImageDoubleTapped(recognizer: UITapGestureRecognizer) {
        
        // Проверка отсутствия у поста лайка текущего пользователя
        guard !cellPost.currentUserLikesThisPost else { return }
        
        // Анимация большого сердца на картинке поста
        let likeAnimation = CAKeyframeAnimation(keyPath: "opacity")
        likeAnimation.values = [0, 1, 1, 0]
        likeAnimation.keyTimes = [0, 0.1, 0.3, 0.6]
        likeAnimation.timingFunctions = [.init(name: .linear),
                                         .init(name: .linear),
                                         .init(name: .easeOut)]
        likeAnimation.duration = 0.6
        bigLikeImage.layer.add(likeAnimation, forKey: nil)
        
        // Обработка лайка
        likeUnlikePost()
    }
    
    @IBAction private func postAuthorTapped(recognizer: UIGestureRecognizer) {
        
        LoadingView.show()
        
        networkService.getUser(withID: cellPost.author) {
            [weak self] result in
            
            switch result {
            case .success(let user):
                self?.delegate?.authorOfPostTapped(user: user)
                LoadingView.hide()
            case .failure(let error):
                self?.delegate?.showErrorAlert(error)
            }
        }
    }
    
    @IBAction func likesCountButtonTapped() {
        guard let cellPost = cellPost else { return }
        delegate?.likesCountLabelTapped(postID: cellPost.id)
    }
    
    @IBAction private func likeButtonTapped() {
        likeUnlikePost()
    }
}
