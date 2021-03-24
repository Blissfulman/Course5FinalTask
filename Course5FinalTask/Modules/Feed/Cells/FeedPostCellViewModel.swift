//
//  FeedPostCellViewModel.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 22.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

// MARK: - Protocols

protocol FeedPostCellViewModelDelegate: AnyObject {
    func authorOfPostTapped(user: UserModel)
    func likesCountButtonTapped(postID: String)
    func updateFeedData()
    func showErrorAlert(_ error: Error)
}

protocol FeedPostCellViewModelProtocol {
    var delegate: FeedPostCellViewModelDelegate? { get set }
    var avatarImageData: Data { get }
    var authorUsername: String { get }
    var createdTime: String { get }
    var postImageData: Data { get }
    var description: String { get }
    var likesCountButtonTitle: String { get }
    var currentUserLikesThisPost: Bool { get }
    var bigLikeNeedAnimating: (() -> Void)? { get set }
    var likeDataNeedUpdating: (() -> Void)? { get set }
    
    init(post: PostModel)
    
    func likeUnlikePost()
    func postAuthorTapped()
    func postImageDoubleTapped()
    func likesCountButtonTapped()
}

final class FeedPostCellViewModel: FeedPostCellViewModelProtocol {
    
    // MARK: - Properties
    
    weak var delegate: FeedPostCellViewModelDelegate?
    
    var avatarImageData: Data {
        post.getAuthorAvatarData()
    }
    
    var authorUsername: String {
        post.authorUsername
    }
    
    var createdTime: String {
        DateFormatter.postDateFormatter.string(from: post.createdTime)
    }
    
    var postImageData: Data {
        post.getImageData()
    }
    
    var description: String {
        post.description
    }
    
    var likesCountButtonTitle: String {
        "Likes: " + String(post.likedByCount)
    }
    
    var currentUserLikesThisPost: Bool {
        post.currentUserLikesThisPost
    }
    
    var bigLikeNeedAnimating: (() -> Void)?
    var likeDataNeedUpdating: (() -> Void)?
    
    private var post: PostModel
    private let dataFetchingService: DataFetchingServiceProtocol = DataFetchingService.shared
    
    // MARK: - Initializers
    
    init(post: PostModel) {
        self.post = post
    }
    
    // MARK: - Public methods
    
    func likeUnlikePost() {
        guard stopIfOffline() else { return }
        
        /// Замыкание, в котором обновляются данные о посте.
        let updatingPost: PostResult = { [weak self] result in
            switch result {
            case .success(let updatedPost):
                self?.post = updatedPost
                self?.likeDataNeedUpdating?()
                self?.delegate?.updateFeedData()
            case .failure(let error):
                guard let error = error as? AppError, error == .offlineError else { return }
                self?.delegate?.showErrorAlert(error)
            }
        }
        
        // Лайк/анлайк
        post.currentUserLikesThisPost
            ? dataFetchingService.unlikePost(withID: post.id, completion: updatingPost)
            : dataFetchingService.likePost(withID: post.id, completion: updatingPost)
    }
    
    func postAuthorTapped() {
        LoadingView.show()
        
        dataFetchingService.fetchUser(withID: post.author) { [weak self] result in
            switch result {
            case .success(let user):
                self?.delegate?.authorOfPostTapped(user: user)
                LoadingView.hide()
            case .failure(let error):
                self?.delegate?.showErrorAlert(error)
            }
        }
    }
    
    func postImageDoubleTapped() {
        guard stopIfOffline() else { return }
        guard !post.currentUserLikesThisPost else { return }
        
        bigLikeNeedAnimating?()
        likeUnlikePost()
    }
    
    func likesCountButtonTapped() {
        guard stopIfOffline() else { return }
        delegate?.likesCountButtonTapped(postID: post.id)
    }
    
    // MARK: - Private methods
    
    /// Возвращает true, если онлайн режим. Возвращает false и инициирует соответствующее оповещение, если оффлайн режим.
    private func stopIfOffline() -> Bool {
        guard NetworkService.isOnline else {
            delegate?.showErrorAlert(AppError.offlineError)
            return false
        }
        return true
    }
}
