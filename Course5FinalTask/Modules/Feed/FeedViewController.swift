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
    
    var viewModel: FeedViewModelProtocol
    
    // MARK: - Initializers
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, viewModel: FeedViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifeсycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        feedTableView.register(FeedPostCell.nib(), forCellReuseIdentifier: FeedPostCell.identifier)
        setupViewModelBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.getFeedPosts()
    }
    
    // MARK: - Private methods
        
    private func setupViewModelBindings() {
        viewModel.tableViewNeedUpdating = { [unowned self] in
            feedTableView.reloadData()
        }
        
        viewModel.authorOfPostTapped = { [unowned self] profileViewModel in
            let profileVC = ProfileViewController(nibName: nil,
                                                  bundle: nil,
                                                  viewModel: profileViewModel)
            navigationController?.pushViewController(profileVC, animated: true)
        }
        
        viewModel.likesCountButtonTapped = { [unowned self] userListViewModel in
            let likesVC = UserListViewController(viewModel: userListViewModel)
            navigationController?.pushViewController(likesVC, animated: true)
        }
        
        viewModel.error.bind { [unowned self] error in
            guard let error = error else { return }
            showAlert(error)
        }
    }
}

// MARK: - Table view data source

extension FeedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostCell.identifier,
                                                 for: indexPath) as! FeedPostCell
        cell.viewModel = viewModel.getFeedPostCellViewModel(at: indexPath)
        cell.configure()
        return cell
    }
}

// MARK: - SharingViewControllerDelegate

extension FeedViewController: SharingViewControllerDelegate {
    
    // Прокрутка ленты в верхнее положение
    func updateAfterPosting() {
        feedTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}
