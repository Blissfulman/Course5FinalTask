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
    
    @IBOutlet weak var feedTableView: UITableView!
    
    // MARK: - Properties
    
    /// Массив постов ленты.
    private var feedPosts = [Post]()
    
    private let networkService: NetworkServiceProtocol = NetworkService.shared
    
    // MARK: - Lifeсycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        feedTableView.dataSource = self
        feedTableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        LoadingView.show()
        
        networkService.getFeed() {
            [weak self] result in
            
            switch result {
            case let .success(feedPosts):
                self?.feedPosts = feedPosts
                self?.feedTableView.reloadData()
                LoadingView.hide()
            case let .failure(error):
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
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedTableViewCell.identifier,
                                                 for: indexPath) as! FeedTableViewCell
        cell.configure(feedPosts[indexPath.row])
        cell.delegate = self
        return cell
    }
}

// MARK: - Table view cell delegate

extension FeedViewController: FeedTableViewCellDelegate {
    
    /// Переход в профиль автора поста.
    func authorOfPostPressed(user: User) {
        guard let profileVC = storyboard?.instantiateViewController(
                withIdentifier: ProfileViewController.identifier
        ) as? ProfileViewController else { return }
        
        profileVC.user = user
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    /// Переход на экран лайкнувших пост пользователей.
    func likesCountLabelPressed(postID: String) {
        let likesVC = UserListViewController(postID: postID, userListType: .likes)
        
        navigationController?.pushViewController(likesVC, animated: true)
    }
    
    /// Обновление данных массива постов ленты (вызывается после лайка/анлайка).
    func updateFeedData() {
        
        networkService.getFeed() {
            [weak self] result in
            
            switch result {
            case let .success(feedPosts):
                self?.feedPosts = feedPosts
            case let .failure(error):
                self?.showAlert(error)
            }
        }
    }
        
    func showErrorAlert(_ error: Error) {
        self.showAlert(error)
    }
}

// MARK: - ShareViewControllerDelegate

extension FeedViewController: ShareViewControllerDelegate {
    // Прокрутка ленты в верхнее положение
    func updateAfterPosting() {
        feedTableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                  at: .top,
                                  animated: true)
    }
}
