//
//  User.swift
//  Course4FinalTask
//
//  Created by User on 04.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - IB Outlets
    /// Коллекция, отображающая информацию о пользователе.
    @IBOutlet weak var profileCollectionView: UICollectionView!
    
    // MARK: - Properties
    static let identifier = "profileViewController"
    
    /// Пользователь, данные которого отображает вью.
    var user: User?
        
    /// Массив фотографий постов пользователя.
    private lazy var photosOfUser = [UIImage]()
    
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
    private let getDataQueue = DispatchQueue(label: "getDataQueue",
                                             qos: .userInteractive)
    
    /// Семафор для установки порядка запросов к провайдеру.
    private let semaphore = DispatchSemaphore(value: 1)
    
    private let appDelegate = AppDelegate.shared
    private let networkService: NetworkServiceProtocol = NetworkService.shared
    
    // MARK: - Lifeсycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileCollectionView.register(
            ProfileCollectionViewCell.nib(),
            forCellWithReuseIdentifier: ProfileCollectionViewCell.identifier
        )
        profileCollectionView.register(
            HeaderProfileCollectionView.nib(),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HeaderProfileCollectionView.identifier
        )

        profileCollectionView.dataSource = self
        
        getCurrentUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUser()
    }
    
    // MARK: - Actions
    @objc func logOutButtonPressed() {
        
        networkService.singOut(token: AppDelegate.token ?? "") { _ in }
        
        let authorizationVC = AuthorizationViewController()
        AppDelegate.token = ""
        appDelegate.window?.rootViewController = authorizationVC
    }
    
    // MARK: - Private methods
    private func addLogOutButton() {
        let logOutButton = UIBarButtonItem(title: "Log Out",
                                           style: .plain,
                                           target: self,
                                           action: #selector(logOutButtonPressed))
        navigationItem.rightBarButtonItem = logOutButton
    }
}

// MARK: - СollectionViewDataSource
extension ProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = profileCollectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: HeaderProfileCollectionView.identifier,
                for: indexPath
            ) as! HeaderProfileCollectionView
            header.delegate = self
            if let user = user, let isCurrentUser = isCurrentUser {
                header.configure(user: user, isCurrentUser: isCurrentUser)
            }
            return header
        default: fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosOfUser.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = profileCollectionView.dequeueReusableCell(
            withReuseIdentifier: ProfileCollectionViewCell.identifier,
            for: indexPath
        ) as! ProfileCollectionViewCell
        cell.configure(photosOfUser[indexPath.item])
        return cell
    }
}

// MARK: - CollectionViewLayout
extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = profileCollectionView.bounds.width / numberOfColumnsOfPhotos
        return CGSize(width: size, height: size)
    }
}

// MARK: - HeaderProfileCollectionViewDelegate
extension ProfileViewController: HeaderProfileCollectionViewDelegate {
    
    // MARK: - Navigation
    /// Переход на подписчиков пользователя.
    func followersLabelPressed() {
        
        guard let user = user else { return }
        
        let followersVC = UserListViewController(userID: user.id,
                                                 userListType: .followers)

        navigationController?.pushViewController(followersVC, animated: true)
    }

    /// Переход на подписки пользователя.
    func followingLabelPressed() {
        
        guard let user = user else { return }
        
        let followingVC = UserListViewController(userID: user.id,
                                                 userListType: .following)
        
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
                DispatchQueue.main.async {
                    self?.user = updatedUser
                    self?.profileCollectionView.reloadData()
                }
            case let .failure(error):
                self?.showAlert(error)
            }
        }
        
        // Подписка/отписка
        user.currentUserFollowsThisUser
            ? networkService.unfollowFromUser(withID: user.id,
                                              token: AppDelegate.token ?? "",
                                              completion: updatingUser)
            : networkService.followToUser(withID: user.id,
                                          token: AppDelegate.token ?? "",
                                          completion: updatingUser)
    }
}

// MARK: - Data recieving methods
extension ProfileViewController {
    
    /// Получение данных о текущем пользователе.
    private func getCurrentUser() {
        
//        LoadingView.show()
        
        // Получение данных о текущем пользователе должно произойти до получения данных об открываемом профиле (которое происходит в методе getUser)
        getDataQueue.async { [weak self] in
            
            guard let self = self else { return }

            self.semaphore.wait()

            self.networkService.getCurrentUser(token: AppDelegate.token ?? "") {
                (result) in
                
                switch result {
                case let .success(currentUser):
                    DispatchQueue.main.async {
                        
                        // Проверка того, открывается ли профиль текущего пользователя
                        if let userID = self.user?.id, userID != currentUser.id {
                            self.isCurrentUser = false
                        } else {
                            self.isCurrentUser = true
                            self.user = currentUser
                        }
                        
                        self.navigationItem.title = self.user?.username
                        self.semaphore.signal()
                    }
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
            self.networkService.getUser(withID: user.id,
                                        token: AppDelegate.token ?? "") {
                (result) in
                
                switch result {
                case let .success(user):
                    DispatchQueue.main.async {
                        self.user = user
                        self.profileCollectionView.reloadData()
                        self.semaphore.signal()
                        
                        // Обновление данных об изображениях постов пользователя
                        self.getPhotos(of: user)
                    }
                case let .failure(error):
                    self.showAlert(error)
                    self.semaphore.signal()
                }
            }
        }
    }

    /// Получение всех изображений постов переданного пользователя.
    private func getPhotos(of user: User) {
                
        networkService.getPostsOfUser(withID: user.id, token: AppDelegate.token ?? "") {
            [weak self] (result) in
            
            guard let self = self else { return }
            
            switch result {
            case let .success(userPosts):
                DispatchQueue.main.async {
                    self.photosOfUser = []
                    userPosts.forEach {
                        guard let image = self.networkService
                                .getImage(fromURL: $0.image) else { return }
                        self.photosOfUser.append(image)
                    }
                    
                    self.profileCollectionView.reloadData()
                    LoadingView.hide()
                }
            case let .failure(error):
                self.showAlert(error)
            }
        }
    }
}
