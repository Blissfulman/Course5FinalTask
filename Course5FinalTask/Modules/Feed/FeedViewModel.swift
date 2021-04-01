//
//  FeedViewModel.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 21.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

// MARK: - Protocols

protocol FeedViewModelProtocol {
    var error: Box<Error?> { get }
    var tableViewNeedUpdating: (() -> Void)? { get set }
    /// Переход в профиль автора поста.
    var authorOfPostTapped: ((_ profileViewModel: ProfileViewModelProtocol) -> Void)? { get set }
    /// Переход на экран лайкнувших пост пользователей.
    var likesCountButtonTapped: ((_ userListViewModel: UserListViewModelProtocol) -> Void)? { get set }
    var numberOfRows: Int { get }
    
    func getFeedPosts()
    func updateFeedPost(_ post: PostModel)
    func getFeedPostCellViewModel(at indexPath: IndexPath) -> FeedPostCellViewModelProtocol
}

final class FeedViewModel: FeedViewModelProtocol {
    
    // MARK: - Properties
    
    var error: Box<Error?> = Box(nil)
    
    var tableViewNeedUpdating: (() -> Void)?
    var authorOfPostTapped: ((_ profileViewModel: ProfileViewModelProtocol) -> Void)?
    var likesCountButtonTapped: ((_ userListViewModel: UserListViewModelProtocol) -> Void)?
    
    var numberOfRows: Int {
        posts.count
    }
    
    private var posts = [PostModel]()
    private let dataFetchingService: DataFetchingServiceProtocol = DataFetchingService.shared
    private let dataStorageService: DataStorageServiceProtocol = DataStorageService.shared
    
    // MARK: - Public methods
    
    func getFeedPosts() {
        LoadingView.show()
        
        dataFetchingService.fetchFeedPosts() { [weak self] result in
            switch result {
            case .success(let feedPosts):
                self?.posts = feedPosts
                self?.tableViewNeedUpdating?()
                LoadingView.hide()
            case .failure(let error):
                self?.error.value = error
            }
        }
    }
    
    func getFeedPostCellViewModel(at indexPath: IndexPath) -> FeedPostCellViewModelProtocol {
        FeedPostCellViewModel(post: posts[indexPath.row], delegate: self)
    }
}

// MARK: - FeedPostCellViewModelDelegate

extension FeedViewModel: FeedPostCellViewModelDelegate {
    
    func authorOfPostTapped(user: UserModel) {
        authorOfPostTapped?(ProfileViewModel(user: user))
    }
    
    func likesCountButtonTapped(postID: String) {
        let userListViewModel = UserListViewModel(postID: postID, userListType: .likes)
        likesCountButtonTapped?(userListViewModel)
    }
    
    // Обновление отдельного поста в массиве постов (вызывается после лайка/анлайка)
    func updateFeedPost(_ post: PostModel) {
        guard let postIndex = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[postIndex] = post
    }
    
    func showErrorAlert(_ error: Error) {
        self.error.value = error
    }
}
