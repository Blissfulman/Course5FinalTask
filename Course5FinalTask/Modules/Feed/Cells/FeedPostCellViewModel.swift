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
    var post: Box<PostModel> { get }
    var bigLikeNeedAnimating: (() -> Void)? { get set }
    var likesCountButtonTitle: String { get }
    
    init(post: PostModel)
    
    func likeUnlikePost()
    func postAuthorTapped()
    func postImageDoubleTapped()
    func likesCountButtonTapped()
}

final class FeedPostCellViewModel: FeedPostCellViewModelProtocol {
    
    // MARK: - Properties
    
    weak var delegate: FeedPostCellViewModelDelegate?
    
    var post: Box<PostModel>
    
    var bigLikeNeedAnimating: (() -> Void)?
    
    var likesCountButtonTitle: String {
        "Likes: " + String(post.value.likedByCount)
    }
    
    private let networkService: NetworkServiceProtocol = NetworkService.shared
    
    // MARK: - Initializers
    
    init(post: PostModel) {
        self.post = Box(post)
    }
    
    func likeUnlikePost() {
        /// Замыкание, в котором обновляются данные о посте.
        let updatingPost: PostResult = { [weak self] result in
            switch result {
            case .success(let updatedPost):
                self?.post.value = updatedPost
                self?.delegate?.updateFeedData()
            case .failure:
                break
            }
        }
        
        // Лайк/анлайк
        post.value.currentUserLikesThisPost
            ? networkService.unlikePost(withID: post.value.id, completion: updatingPost)
            : networkService.likePost(withID: post.value.id, completion: updatingPost)
    }
    
    func postAuthorTapped() {
        LoadingView.show()
        
        networkService.fetchUser(withID: post.value.author) { [weak self] result in
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
        guard !post.value.currentUserLikesThisPost else { return }
        
        likeUnlikePost()
        bigLikeNeedAnimating?()
    }
    
    func likesCountButtonTapped() {
        delegate?.likesCountButtonTapped(postID: post.value.id)
    }
}
