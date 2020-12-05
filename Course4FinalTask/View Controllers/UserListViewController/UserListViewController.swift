//
//  YellowViewController.swift
//  Course4FinalTask
//
//  Created by User on 09.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class UserListViewController: UIViewController {
    
    // MARK: - Properties    
    /// Список отображаемых в таблице пользователей.
    private var userList = [User]()
    
    /// Таблица пользователей.
    private lazy var userListTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    /// Высота строки в таблице.
    private let heightForRow: CGFloat = 45
    
    private let networkService: NetworkServiceProtocol = NetworkService()
    
    // MARK: - Initializers
    convenience init(userList: [User]) {
        self.init()
        self.userList = userList
    }
    
    // MARK: - Lifeсycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
    }
    
    // Снятие выделения с ячейки при возврате на вью
    override func viewDidAppear(_ animated: Bool) {
        guard let selectedRow = userListTableView
                .indexPathForSelectedRow else { return }
        userListTableView.deselectRow(at: selectedRow, animated: true)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(userListTableView)
    }
    
    // MARK: - Setup layout
    private func setupLayout() {
        NSLayoutConstraint.activate([
            userListTableView.topAnchor.constraint(equalTo: view.topAnchor),
            userListTableView.leadingAnchor
                .constraint(equalTo: view.leadingAnchor),
            userListTableView.trailingAnchor
                .constraint(equalTo: view.trailingAnchor),
            userListTableView.bottomAnchor
                .constraint(equalTo: view.bottomAnchor)
        ])
    }
}
 
extension UserListViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - TableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        var content = cell.defaultContentConfiguration()
        content.directionalLayoutMargins = .init(top: 0, leading: 0,
                                                 bottom: 1, trailing: 0)
        
        let imageURL = userList[indexPath.row].avatar
        content.image = networkService.getImage(fromURL: imageURL)
        content.text = userList[indexPath.row].fullName
        
        cell.contentConfiguration = content
        return cell
    }

    // MARK: - TableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRow
    }
    
    // Переход на вью пользователя
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: AppDelegate.storyboardName,
                                      bundle: nil)
        
        guard let profileVC = storyboard.instantiateViewController(withIdentifier: ProfileViewController.identifier) as? ProfileViewController else { return }
        
        profileVC.user = userList[indexPath.row]
        navigationController?.pushViewController(profileVC, animated: true)
    }
}
