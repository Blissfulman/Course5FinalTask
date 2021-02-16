//
//  UserListViewController.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 09.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class UserListViewController: UITableViewController {
    
    // MARK: - Properties
    
    var viewModel: UserListViewModelProtocol!
    
    // MARK: - Lifeсycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.updateUserList()
    }
    
    // Снятие выделения с ячейки при возврате на вью
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let selectedRow = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRow(at: selectedRow, animated: true)
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        title = viewModel.title
        viewModel.userList.bind { [weak self] _ in
            self?.tableView.reloadData()
        }
        viewModel.error.bind { [weak self] error in
            guard let error = error else { return }
            self?.showAlert(error)
        }
    }
}

// MARK: - Table view data source

extension UserListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        var content = cell.defaultContentConfiguration()
        content.directionalLayoutMargins = .init(top: 0, leading: 0, bottom: 1, trailing: 0)
        content.image = UIImage(data: viewModel.getUserImageData(atIndexPath: indexPath) ?? Data())
        content.text = viewModel.getUserFullName(atIndexPath: indexPath)
        
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - Table view delegate

extension UserListViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UIConstants.userListHeightForRow
    }
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: AppDelegate.storyboardName, bundle: nil)
        
        guard let profileVC = storyboard.instantiateViewController(
            withIdentifier: ProfileViewController.identifier
        ) as? ProfileViewController else { return }
        
        profileVC.user = viewModel.getUser(atIndexPath: indexPath)
        navigationController?.pushViewController(profileVC, animated: true)
    }
}
