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
    static let identifier = "ProfileViewController"
    
    /// Пользователь, данные которого отображает вью.
    var user: User?
        
    /// Массив фотографий постов пользователя.
    private lazy var photosOfUser = [UIImage]()
    
    /// Логическое значение, указывающее, является ли отображаемый профиль, профилем текущего пользователя.
    private var isCurrentUser: Bool?

    /// Количество колонок в представлении фотографий.
    private let numberOfColumnsOfPhotos: CGFloat = 3
    
    /// Очередь для выстраивания запросов данных у провайдера.
    private let getDataQueue = DispatchQueue(label: "getDataQueue",
                                             qos: .userInteractive)
    /// Семафор для установки порядка запросов к провайдеру.
    private let semaphore = DispatchSemaphore(value: 1)
    
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
        
        // Получение данных о текущем пользователе должно произойти до получения данных об открываемом профиле (которое происходит в методе viewWillAppear)
        getDataQueue.async { [weak self] in
            
            guard let self = self else { return }

            self.semaphore.wait()

            self.networkService.getCurrentUser(token: AppDelegate.token ?? "") {
                (currentUser) in
                
                DispatchQueue.main.async {
                    guard let currentUser = currentUser else {
                        self.showAlert(title: "Unknown error!",
                                       message: "Please, try again later")
                        self.semaphore.signal()
                        return
                    }
                    
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
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        LoadingView.show()
        
        // Получение данных об открываемом пользователе
        getDataQueue.async { [weak self] in
            
            guard let self = self else { return }

            self.semaphore.wait()
            
            guard let user = self.user else { return }
            
            // Обновление данных о пользователе
            self.networkService.getUser(withID: user.id,
                                        token: AppDelegate.token ?? "") {
                (user) in
                
                DispatchQueue.main.async {
                    guard let user = user else {
                        self.showAlert(title: "Unknown error!",
                                       message: "Please, try again later")
                        self.semaphore.signal()
                        return
                    }
                    
                    self.user = user
                    self.profileCollectionView.reloadData()
                    self.semaphore.signal()
                    
                    // Обновление данных об изображениях постов пользователя
                    self.getPhotos(user: user)
                }
            }
        }
    }
}

// MARK: - СollectionViewDataSource
extension ProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = profileCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderProfileCollectionView.identifier, for: indexPath) as! HeaderProfileCollectionView
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
        let cell = profileCollectionView.dequeueReusableCell(withReuseIdentifier: ProfileCollectionViewCell.identifier,
                                                             for: indexPath) as! ProfileCollectionViewCell
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
    func tapFollowersLabel() {
        
        guard let user = user else { return }
        
        let followersVC = UserListViewController(userID: user.id,
                                                 userListType: .followers)

        navigationController?.pushViewController(followersVC, animated: true)
    }

    /// Переход на подписки пользователя.
    func tapFollowingLabel() {
        
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
        let updateUser: UserResult = { [weak self] (updatedUser: User?) in
                        
            DispatchQueue.main.async {
                guard let updatedUser = updatedUser else {
                    self?.showAlert(title: "Unknown error!",
                                    message: "Please, try again later")
                    return
                }
                
                self?.user = updatedUser
                self?.profileCollectionView.reloadData()
            }
        }
        
        // Подписка/отписка
        if user.currentUserFollowsThisUser {
            networkService.unfollowFromUser(withID: user.id,
                                            token: AppDelegate.token ?? "",
                                            completion: updateUser)
        } else {
            networkService.followToUser(withID: user.id,
                                        token: AppDelegate.token ?? "",
                                        completion: updateUser)
        }
    }
}

// MARK: - Data recieving methods
extension ProfileViewController {
    
    /// Получение всех изображений постов пользователя с переданным ID.
    private func getPhotos(user: User) {
                
        networkService.getPostsOfUser(withID: user.id, token: AppDelegate.token ?? "") {
            [weak self] (userPosts) in

            guard let self = self else { return }

            DispatchQueue.main.async {

                defer {
                    LoadingView.hide()
                }

                guard let userPosts = userPosts else {
                    self.showAlert(title: "Unknown error!",
                                   message: "Please, try again later")
                    return
                }

                self.photosOfUser = []
                userPosts.forEach {
                    guard let image = self.networkService.getImage(fromURL: $0.image) else { return }
                    self.photosOfUser.append(image)
                }

                self.profileCollectionView.reloadData()
            }
        }
    }
}
