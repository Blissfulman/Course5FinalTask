//
//  FeedTableViewCellDelegate.swift
//  Course4FinalTask
//
//  Created by User on 04.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

protocol FeedTableViewCellDelegate: UIViewController {
    func authorOfPostPressed(user: User)
    func likesCountLabelPressed(postID: String)
    func updateFeedData()
    func showErrorAlert(_ error: Error)
}

final class FeedTableViewCell: UITableViewCell {

    // MARK: - IB Outlets
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var authorUsernameLabel: UILabel!
    @IBOutlet weak var createdTimeLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var bigLikeImage: UIImageView!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - Properties
    static let identifier = "feedPostCell"
    
    weak var delegate: FeedTableViewCellDelegate?
    
    /// Пост ячейки
    private var cellPost: Post! {
        didSet {
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self else { return }
                
                self.likeImage.tintColor = self.cellPost
                    .currentUserLikesThisPost ? .systemBlue : .lightGray
                self.likesCountLabel.text = "Likes: "
                    + String(self.cellPost.likedByCount)
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
    func configure(_ post: Post) {
                
        // Сохранения поста ячейки
        cellPost = post

        // Заполнение всех элементов ячейки данными
        avatarImage.getImage(fromURL: post.authorAvatar)
        authorUsernameLabel.text = post.authorUsername
        createdTimeLabel.text = DateFormatter.postDateFormatter
            .string(from: post.createdTime)
        postImage.getImage(fromURL: post.image)
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
            ? networkService.unlikePost(withID: cellPost.id,
                                        completion: updatingPost)
            : networkService.likePost(withID: cellPost.id,
                                      completion: updatingPost)
    }
}

extension FeedTableViewCell {
    
    // MARK: - Setup gesture recognizers
    private func setupGestureRecognizers() {
        
        // Жест двойного тапа по картинке поста
        let postImageGR = UITapGestureRecognizer(
            target: self, action: #selector(postImagePressed(recognizer:))
        )
        postImageGR.numberOfTapsRequired = 2
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(postImageGR)
        
        // Жест тапа по автору поста (по аватарке)
        let authorAvatarGR = UITapGestureRecognizer(
            target: self, action: #selector(postAuthorPressed(recognizer:))
        )
        avatarImage.isUserInteractionEnabled = true
        avatarImage.addGestureRecognizer(authorAvatarGR)
        
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
        likeImage.isUserInteractionEnabled = true
        likeImage.addGestureRecognizer(likeImageGR)
    }

    // MARK: - Actions
    /// Двойной тап по картинке поста.
    @IBAction func postImagePressed(recognizer: UITapGestureRecognizer) {
        
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
