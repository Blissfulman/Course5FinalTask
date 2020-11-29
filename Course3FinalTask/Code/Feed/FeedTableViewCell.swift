//
//  FeedTableViewCell.swift
//  Course2FinalTask
//
//  Created by User on 04.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

protocol FeedTableViewCellDelegate: UIViewController {
    func tapAuthorOfPost(user: User)
    func tapLikesCountLabel(userList: [User])
    func updateFeedData()
    func showBlockView()
    func hideBlockView()
    func showErrorAlert()
}

class FeedTableViewCell: UITableViewCell {

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
    private var cellPost: Post!
    
    /// Логическое значение, указывающее, лайкнул ли текущий пользователь данный пост.
    private var isLiked = false
    
    /// Количество лайков на этой публикации.
    private var likedByCount = 0
    
    // MARK: - Lifeсycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupGestureRecognizers()
    }
    
    // MARK: - Setup the cell
    func configure(_ post: Post) {
                
        // Запись переменных поста
//        isLiked = post.currentUserLikesThisPost
//        likedByCount = post.likedByCount
//        cellPost = post
//
//        // Заполнение всех элементов ячейки данными
//        avatarImage.image = post.authorAvatar
//        authorUsernameLabel.text = post.authorUsername
//        createdTimeLabel.text = setDateAndTime(post.createdTime)
//        postImage.image = post.image
//        updateLikeData()
//        descriptionLabel.text = post.description
    }
    
    private func setDateAndTime(_ date: Date) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .medium
        dateFormat.timeStyle = .medium
        dateFormat.doesRelativeDateFormatting = true
        return dateFormat.string(from: date as Date)
    }
    
    private func updateLikeData() {
        likeImage.tintColor = isLiked ? .systemBlue : .lightGray
        likesCountLabel.text = "Likes: " + String(likedByCount)
    }
    
    // MARK: - Working with likes
    /// Лайк, либо отмена лайка поста.
    private func likeUnlikePost() {

        // Лайк/анлайк поста
//        if isLiked {
//            DataProviders.shared.postsDataProvider.unlikePost(with: cellPost.id, queue: .main) { _ in }
//            isLiked = false
//            likedByCount -= 1
//        } else {
//            DataProviders.shared.postsDataProvider.likePost(with: cellPost.id, queue: .main) { _ in }
//            isLiked = true
//            likedByCount += 1
//        }
        
        // Обновление данных о лайках поста в ячейке (количество и цвет сердечка)
        updateLikeData()
        
        // Получение обновлённого поста
//        getPost(postID: self.cellPost.id) {
//            [weak self] (updatedPost) in
//            
//            guard let `self` = self else { return }
//            
//            guard let updatedPost = updatedPost else {
//                self.delegate?.showErrorAlert()
//                return
//            }
//            
//            // Запись переменных поста
//            self.isLiked = updatedPost.currentUserLikesThisPost
//            self.likedByCount = updatedPost.likedByCount
//            self.cellPost = updatedPost
//        }
        
        // Обновление данных в массиве постов
        delegate?.updateFeedData()
    }
}

extension FeedTableViewCell {
    
    // MARK: - Setup gesture recognizers
    private func setupGestureRecognizers() {
        
        // Жест двойного тапа по картинке поста
        let postImageGR = UITapGestureRecognizer(
            target: self, action: #selector(tapPostImage(recognizer:))
        )
        postImageGR.numberOfTapsRequired = 2
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(postImageGR)
        
        // Жест тапа по автору поста (по аватарке)
        let authorAvatarGR = UITapGestureRecognizer(
            target: self, action: #selector(tapAuthorOfPost(recognizer:))
        )
        avatarImage.isUserInteractionEnabled = true
        avatarImage.addGestureRecognizer(authorAvatarGR)
        
        // Жест тапа по автору поста (по username)
        let authorUsernameGR = UITapGestureRecognizer(
            target: self, action: #selector(tapAuthorOfPost(recognizer:))
        )
        authorUsernameLabel.isUserInteractionEnabled = true
        authorUsernameLabel.addGestureRecognizer(authorUsernameGR)
        
        // Жест тапа по количеству лайков поста
        let likesCountGR = UITapGestureRecognizer(
            target: self, action: #selector(tapLikesCountLabel(recognizer:))
        )
        likesCountLabel.isUserInteractionEnabled = true
        likesCountLabel.addGestureRecognizer(likesCountGR)
        
        // Жест тапа по сердечку под постом
        let likeImageGR = UITapGestureRecognizer(
            target: self, action: #selector(tapLikeImage(recognizer:))
        )
        likeImage.isUserInteractionEnabled = true
        likeImage.addGestureRecognizer(likeImageGR)
    }

    // MARK: - Actions
    /// Двойной тап по картинке поста.
    @IBAction func tapPostImage(recognizer: UITapGestureRecognizer) {
        
        // Проверка отсутствия у поста лайка текущего пользователя
        guard !isLiked else { return }
        
        // Анимация большого сердца
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
    @IBAction func tapAuthorOfPost(recognizer: UIGestureRecognizer) {
        
        delegate?.showBlockView()
        
//        getUser(userID: cellPost.author) {
//            [weak self] (user) in
//
//            guard let `self` = self else { return }
//
//            guard let user = user else {
//                self.delegate?.showErrorAlert()
//                self.delegate?.hideBlockView()
//                return
//            }
//
//            self.delegate?.tapAuthorOfPost(user: user)
//            self.delegate?.hideBlockView()
//        }
    }
    
    /// Тап по количеству лайков поста.
    @IBAction func tapLikesCountLabel(recognizer: UIGestureRecognizer) {
        
        delegate?.showBlockView()
        
        // Создание массива пользователей, лайкнувших пост
//        getUsersLikedPost(postID: cellPost.id) {
//            [weak self] (userList) in
//
//            guard let `self` = self else { return }
//
//            guard let userList = userList else {
//                self.delegate?.showErrorAlert()
//                self.delegate?.hideBlockView()
//                return
//            }
//
//            self.delegate?.tapLikesCountLabel(userList: userList)
//            self.delegate?.hideBlockView()
//        }
    }
    
    /// Тап  по сердечку под постом.
    @IBAction func tapLikeImage(recognizer: UIGestureRecognizer) {
        likeUnlikePost()
    }
}

// MARK: - Data recieving methods
extension FeedTableViewCell {
    
    /// Получение публикации с переданным ID.
//    private func getPost(postID: Post.Identifier, completion: @escaping (Post?) -> Void) {
//        DataProviders.shared.postsDataProvider.post(with: postID, queue: .global(qos: .userInteractive)) {
//            (post) in
//            DispatchQueue.main.async {
//                completion(post)
//            }
//        }
//    }
    
    /// Получение пользователя с переданным ID.
//    private func getUser(userID: User.Identifier, completion: @escaping (User?) -> Void) {
//        DataProviders.shared.usersDataProvider.user(with: userID, queue: .global(qos: .userInteractive)) {
//            (user) in
//            DispatchQueue.main.async {
//                completion(user)
//            }
//        }
//    }
    
    /// Получение пользователей, поставивших лайк на публикацию.
//    private func getUsersLikedPost(postID: Post.Identifier, completion: @escaping ([User]?) -> Void) {
//        DataProviders.shared.postsDataProvider.usersLikedPost(with: postID, queue: .global(qos: .userInteractive)) {
//            (usersLikedPost) in
//            DispatchQueue.main.async {
//                completion(usersLikedPost)
//            }
//        }
//    }
}
