//
//  FeedViewController.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 22.07.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class FeedViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var feedTableView: UITableView!
    
    // MARK: - Properties
    
    /// Массив постов ленты.
    private var feedPosts = [PostModel]()
    
    private let networkService: NetworkServiceProtocol = NetworkService.shared
    
    // MARK: - Lifeсycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        feedTableView.register(FeedPostCell.nib(), forCellReuseIdentifier: FeedPostCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        LoadingView.show()
        
        networkService.fetchFeed() {
            [weak self] result in
            
            switch result {
            case .success(let feedPosts):
                self?.feedPosts = feedPosts
                self?.feedTableView.reloadData()
                LoadingView.hide()
            case .failure(let error):
                self?.showAlert(error)
            }
        }
    }
}

// MARK: - Table view data source

extension FeedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        feedPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostCell.identifier,
                                                 for: indexPath) as! FeedPostCell
        cell.configure(feedPosts[indexPath.row])
        cell.delegate = self
        return cell
    }
}

// MARK: - Table view cell delegate

extension FeedViewController: FeedPostCellDelegate {
    
    /// Переход в профиль автора поста.
    func authorOfPostTapped(user: UserModel) {
        let profileVC = ProfileViewController(nibName: nil,
                                              bundle: nil,
                                              viewModel: ProfileViewModel(user: user))
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    /// Переход на экран лайкнувших пост пользователей.
    func likesCountLabelTapped(postID: String) {
        let userListVM = UserListViewModel(postID: postID, userListType: .likes)
        let likesVC = UserListViewController(viewModel: userListVM)
        navigationController?.pushViewController(likesVC, animated: true)
    }
    
    /// Обновление данных массива постов ленты (вызывается после лайка/анлайка).
    func updateFeedData() {
        networkService.fetchFeed() { [weak self] result in
            
            switch result {
            case .success(let feedPosts):
                self?.feedPosts = feedPosts
            case .failure(let error):
                self?.showAlert(error)
            }
        }
    }
        
    func showErrorAlert(_ error: Error) {
        self.showAlert(error)
    }
}

// MARK: - SharingViewControllerDelegate

extension FeedViewController: SharingViewControllerDelegate {
    
    // Прокрутка ленты в верхнее положение
    func updateAfterPosting() {
        feedTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}
