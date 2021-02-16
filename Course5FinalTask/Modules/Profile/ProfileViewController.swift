//
//  ProfileViewController.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 04.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Outlets
    
    /// Коллекция, отображающая информацию о пользователе.
    @IBOutlet private weak var profileCollectionView: UICollectionView!
    
    // MARK: - Properties
    
    static let identifier = String(describing: ProfileViewController.self)
    
    /// Пользователь, данные которого отображает вью.
    var user: UserModel?
        
    /// Массив постов пользователя.
    private lazy var userPosts = [PostModel]()
    
    /// Логическое значение, указывающее, является ли отображаемый профиль, профилем текущего пользователя.
    private var isCurrentUser: Bool? {
        willSet {
            if let newValue = newValue, newValue {
                addLogOutButton()
            }
        }
    }

    /// Количество колонок в представлении фотографий.
    private let numberOfColumnsOfPhotos: CGFloat = 3
    
    /// Очередь для выстраивания запросов данных у провайдера.
    private let getDataQueue = DispatchQueue(label: "getDataQueue", qos: .userInteractive)
    
    /// Семафор для установки порядка запросов к провайдеру.
    private let semaphore = DispatchSemaphore(value: 1)
    
    private let appDelegate = AppDelegate.shared
    private let networkService: NetworkServiceProtocol = NetworkService.shared
    
    // MARK: - Lifeсycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileCollectionView.register(
            ProfileHeader.nib(),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ProfileHeader.identifier
        )
        profileCollectionView.register(ProfilePhotoCell.nib(),
                                       forCellWithReuseIdentifier: ProfilePhotoCell.identifier)
        profileCollectionView.dataSource = self
        
        getCurrentUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getUser()
    }
    
    // MARK: - Actions
    
    @objc private func logOutButtonPressed() {
        networkService.singOut() { _ in }
        
        let authorizationVC = AuthorizationViewController()
        NetworkService.token = ""
        appDelegate.window?.rootViewController = authorizationVC
    }
    
    // MARK: - Private methods
    
    private func addLogOutButton() {
        let logOutButton = UIBarButtonItem(
            title: "Log Out", style: .plain, target: self, action: #selector(logOutButtonPressed)
        )
        navigationItem.rightBarButtonItem = logOutButton
    }
}

// MARK: - Сollection view data source

extension ProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = profileCollectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: ProfileHeader.identifier,
                for: indexPath
            ) as! ProfileHeader
            
            header.delegate = self
            
            if let user = user,
               let isCurrentUser = isCurrentUser {
                header.configure(user: user, isCurrentUser: isCurrentUser)
            }
            return header
        default: fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        userPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = profileCollectionView.dequeueReusableCell(
            withReuseIdentifier: ProfilePhotoCell.identifier, for: indexPath
        ) as! ProfilePhotoCell
        
        cell.configure(userPosts[indexPath.item])
        return cell
    }
}

// MARK: - Collection view layout

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = profileCollectionView.bounds.width / numberOfColumnsOfPhotos
        return CGSize(width: size, height: size)
    }
}

// MARK: - HeaderProfileCollectionViewDelegate

extension ProfileViewController: ProfileHeaderDelegate {
    
    // MARK: - Navigation
    
    /// Переход на подписчиков пользователя.
    func followersLabelPressed() {
        
        guard let user = user else { return }
        
        let followersVC = UserListViewController()
        followersVC.viewModel = UserListViewModel(userID: user.id, userListType: .followers)
        
        navigationController?.pushViewController(followersVC, animated: true)
    }

    /// Переход на подписки пользователя.
    func followingLabelPressed() {
        
        guard let user = user else { return }
        
        let followingVC = UserListViewController()
        followingVC.viewModel = UserListViewModel(userID: user.id, userListType: .following)
        
        navigationController?.pushViewController(followingVC, animated: true)
    }
    
    // MARK: - Working with followings
    
    /// Подписка, либо отписка от пользователя.
    func followUnfollowUser() {
        
        guard let user = user else { return }
        
        /// Замыкание, в котором обновляются данные о пользователе.
        let updatingUser: UserResult = { [weak self] result in
            
            switch result {
            case let .success(updatedUser):
                self?.user = updatedUser
                self?.profileCollectionView.reloadData()
            case let .failure(error):
                self?.showAlert(error)
            }
        }
        
        // Подписка/отписка
        user.currentUserFollowsThisUser
            ? networkService.unfollowFromUser(withID: user.id, completion: updatingUser)
            : networkService.followToUser(withID: user.id, completion: updatingUser)
    }
}

// MARK: - Data recieving methods

extension ProfileViewController {
    
    /// Получение данных о текущем пользователе.
    private func getCurrentUser() {
                
        // Получение данных о текущем пользователе должно произойти до получения данных об открываемом профиле (которое происходит в методе getUser)
        getDataQueue.async { [weak self] in
            
            guard let self = self else { return }

            self.semaphore.wait()

            self.networkService.getCurrentUser() { result in
                
                switch result {
                case let .success(currentUser):
                    // Проверка того, открывается ли профиль текущего пользователя
                    if let userID = self.user?.id, userID != currentUser.id {
                        self.isCurrentUser = false
                    } else {
                        self.isCurrentUser = true
                        self.user = currentUser
                    }
                    
                    self.navigationItem.title = self.user?.username
                    self.semaphore.signal()
                case let .failure(error):
                    self.showAlert(error)
                    self.semaphore.signal()
                }
            }
        }
    }
    
    /// Получение данных об открываемом пользователе.
    private func getUser() {
        LoadingView.show()
        
        getDataQueue.async { [weak self] in
            
            guard let self = self else { return }

            self.semaphore.wait()
            
            // Эта строка после семафора, потому что наличие user можно проверять только после окончания выполнения функции getCurrentUser()
            guard let user = self.user else { return }
            
            // Обновление данных о пользователе
            self.networkService.getUser(withID: user.id) { result in
                
                switch result {
                case let .success(user):
                    self.user = user
                    self.profileCollectionView.reloadData()
                    self.semaphore.signal()
                    
                    // Обновление данных об изображениях постов пользователя
                    self.getUserPosts(of: user)
                case let .failure(error):
                    self.showAlert(error)
                    self.semaphore.signal()
                }
            }
        }
    }

    /// Получение постов пользователя.
    private func getUserPosts(of user: UserModel) {
                
        networkService.getPostsOfUser(withID: user.id) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case let .success(userPosts):
                self.userPosts = userPosts
                self.profileCollectionView.reloadData()
                LoadingView.hide()
            case let .failure(error):
                self.showAlert(error)
            }
        }
    }
}
