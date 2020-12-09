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
    /// ID пользователя, подписчиков либо подписок которого, требуется отобразить.
    private var userID: String!
    
    /// ID поста, лайкнувших пользователей которого, требуется отобрвзить.
    private var postID: String!
    
    /// Тип списка отображаемых пользователей.
    private var userListType: UserListType!
    
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
    
    private let networkService: NetworkServiceProtocol = NetworkService.shared
    
    // MARK: - Initializers
    convenience init(postID: String? = nil,
                     userID: String? = nil,
                     userListType: UserListType) {
        self.init()
        self.userID = userID
        self.postID = postID
        self.userListType = userListType
    }
    
    // MARK: - Lifeсycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        updateUserList()
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
        title = userListType.rawValue
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
    
    // MARK: - Updating user list data
    private func updateUserList() {
        
        LoadingView.show()
        
        /// Замыкание, в котором обновляется список отображаемых пользователей.
        let updateUserList: UsersResult = { [weak self] (userList) in
            
            defer {
                LoadingView.hide()
            }
            
            DispatchQueue.main.async {
                
                guard let userList = userList else {
                    self?.showAlert(title: "Unknown error!",
                                    message: "Please, try again later")
                    return
                }
                self?.userList = userList
                self?.userListTableView.reloadData()
            }
        }
        
        switch userListType {
        case .likes:
            // Получение пользователей, лайкнувших пост
            networkService.getUsersLikedPost(withID: postID,
                                             token: AppDelegate.token ?? "",
                                             completion: updateUserList)
        case .followers:
            // Получение подписчиков
            networkService.getUsersFollowingUser(withID: userID,
                                                 token: AppDelegate.token ?? "",
                                                 completion: updateUserList)
        case .following:
            // Получение подписок
            networkService.getUsersFollowedByUser(withID: userID,
                                                  token: AppDelegate.token ?? "",
                                                  completion: updateUserList)
        case .none:
            break
        }
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
