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
    var numberOfRows: Int { get }
    
    func getFeedPosts(withUpdatingTableView: Bool)
    func getFeedPostCellViewModel(at indexPath: IndexPath) -> FeedPostCellViewModelProtocol
}

final class FeedViewModel: FeedViewModelProtocol {
    
    // MARK: - Properties
    
    var error: Box<Error?> = Box(nil)
    
    var tableViewNeedUpdating: (() -> Void)?
    
    var numberOfRows: Int {
        posts.count
    }
    
    private var posts = [PostModel]()
    private let dataFetchingService: DataFetchingServiceProtocol = DataFetchingService.shared
    private let dataStorageService: DataStorageServiceProtocol = DataStorageService.shared
    
    // MARK: - Public methods
    
    func getFeedPosts(withUpdatingTableView: Bool) {
        if withUpdatingTableView {
            LoadingView.show()
        }
        
        dataFetchingService.fetchFeedPosts() { [weak self] result in
            switch result {
            case .success(let feedPosts):
                print(feedPosts.count) // TEMP
                self?.posts = feedPosts
                if withUpdatingTableView {
                    self?.tableViewNeedUpdating?()
                }
                LoadingView.hide()
            case .failure(let error):
                self?.error.value = error
            }
        }
    }
    
    func getFeedPostCellViewModel(at indexPath: IndexPath) -> FeedPostCellViewModelProtocol {
        FeedPostCellViewModel(post: posts[indexPath.row])
    }
}
