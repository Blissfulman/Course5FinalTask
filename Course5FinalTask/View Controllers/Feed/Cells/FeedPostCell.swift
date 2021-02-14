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
    func authorOfPostPressed(user: UserModel)
    func likesCountLabelPressed(postID: String)
    func updateFeedData()
    func showErrorAlert(_ error: Error)
}

final class FeedPostCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var authorUsernameLabel: UILabel!
    @IBOutlet private weak var createdTimeLabel: UILabel!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var bigLikeImage: UIImageView!
    @IBOutlet private weak var likesCountLabel: UILabel!
    @IBOutlet private weak var likeImageView: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    // MARK: - Properties
    
    static let identifier = String(describing: FeedPostCell.self)
    
    weak var delegate: FeedPostCellDelegate?
    
    /// Пост ячейки
    private var cellPost: PostModel! {
        didSet {
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self else { return }
                
                self.likeImageView.tintColor = self.cellPost.currentUserLikesThisPost
                    ? .systemBlue
                    : .lightGray
                self.likesCountLabel.text = "Likes: " + String(self.cellPost.likedByCount)
            }
        }
    }
    
    private let networkService: NetworkServiceProtocol = NetworkService.shared
    
    // MARK: - Lifeсycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupGestureRecognizers()
    }
    
    // MARK: - Setup the cell
    
    func configure(_ post: PostModel) {
                
        // Сохранения поста ячейки
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
            case let .success(updatedPost):
                self?.cellPost = updatedPost
                
                // Обновление данных в массиве постов
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
            target: self, action: #selector(postAuthorPressed(recognizer:))
        )
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(authorAvatarGR)
        
        // Жест тапа по автору поста (по username)
        let authorUsernameGR = UITapGestureRecognizer(
            target: self, action: #selector(postAuthorPressed(recognizer:))
        )
        authorUsernameLabel.isUserInteractionEnabled = true
        authorUsernameLabel.addGestureRecognizer(authorUsernameGR)
        
        // Жест тапа по количеству лайков поста
        let likesCountGR = UITapGestureRecognizer(
            target: self, action: #selector(likesCountLabelPressed(recognizer:))
        )
        likesCountLabel.isUserInteractionEnabled = true
        likesCountLabel.addGestureRecognizer(likesCountGR)
        
        // Жест тапа по сердечку под постом
        let likeImageGR = UITapGestureRecognizer(
            target: self, action: #selector(likeImagePressed(recognizer:))
        )
        likeImageView.isUserInteractionEnabled = true
        likeImageView.addGestureRecognizer(likeImageGR)
    }
}

// MARK: - Actions

extension FeedPostCell {
    
    /// Двойной тап по картинке поста.
    @IBAction func postImageDoubleTapped(recognizer: UITapGestureRecognizer) {
        
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
    
    /// Тап по автору поста.
    @IBAction func postAuthorPressed(recognizer: UIGestureRecognizer) {
        
        LoadingView.show()
        
        networkService.getUser(withID: cellPost.author) {
            [weak self] result in
            
            switch result {
            case let .success(user):
                self?.delegate?.authorOfPostPressed(user: user)
                LoadingView.hide()
            case let .failure(error):
                self?.delegate?.showErrorAlert(error)
            }
        }
    }
    
    /// Тап по количеству лайков поста.
    @IBAction func likesCountLabelPressed(recognizer: UIGestureRecognizer) {
        guard let cellPost = cellPost else { return }
        delegate?.likesCountLabelPressed(postID: cellPost.id)
    }
    
    /// Тап  по сердечку под постом.
    @IBAction func likeImagePressed(recognizer: UIGestureRecognizer) {
        likeUnlikePost()
    }
}
