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
        
        getCurrentUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUser()
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
            
            DispatchQueue.main.async {
                
                switch result {
                case let .success(updatedUser):
                    self?.user = updatedUser
                    self?.profileCollectionView.reloadData()
                case .failure:
                    self?.showAlert(title: "Unknown error!",
                                    message: "Please, try again later")
                    
                }
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
                
                DispatchQueue.main.async {
                    
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
                    case .failure:
                        self.showAlert(title: "Unknown error!",
                                       message: "Please, try again later")
                        self.semaphore.signal()
                    }
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
                
                DispatchQueue.main.async {
                    
                    switch result {
                    case let .success(user):
                        self.user = user
                        self.profileCollectionView.reloadData()
                        self.semaphore.signal()
                        
                        // Обновление данных об изображениях постов пользователя
                        self.getPhotos(of: user)
                    case.failure:
                        self.showAlert(title: "Unknown error!",
                                       message: "Please, try again later")
                        self.semaphore.signal()
                    }
                }
            }
        }
    }

    /// Получение всех изображений постов переданного пользователя.
    private func getPhotos(of user: User) {
                
        networkService.getPostsOfUser(withID: user.id, token: AppDelegate.token ?? "") {
            [weak self] (result) in

            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                defer {
                    LoadingView.hide()
                }
                
                switch result {
                case let .success(userPosts):
                    self.photosOfUser = []
                    userPosts.forEach {
                        guard let image = self.networkService.getImage(fromURL: $0.image) else { return }
                        self.photosOfUser.append(image)
                    }
                    
                    self.profileCollectionView.reloadData()
                case .failure:
                    self.showAlert(title: "Unknown error!",
                                   message: "Please, try again later")
                }
            }
        }
    }
}
