//
//  ProfileViewModel.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 20.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

// MARK: - Protocols

protocol ProfileViewModelProtocol {
    var user: Box<UserModel?> { get }
    var isCurrentUser: Box<Bool?> { get }
    var userPosts: Box<[PostModel]> { get }
    var error: Box<Error?> { get }
    var needLogOut: (() -> Void)? { get set }
    var numberOfItems: Int { get }
    
    init(user: UserModel?)
    
    func getCurrentUser()
    func getUser()
    func getCellData(at indexPath: IndexPath) -> Data
    func logOutButtonDidTap()
    func getProfileHeaderViewModel(delegate: ProfileHeaderViewModelDelegate) -> ProfileHeaderViewModelProtocol?
    func getUserListViewModel(withUserListType userListType: UserListType) -> UserListViewModelProtocol?
    func getAuthorizationViewModel() -> AuthorizationViewModelProtocol
}

final class ProfileViewModel: ProfileViewModelProtocol {
    
    // MARK: - Properties
    
    var user: Box<UserModel?> = Box(nil)
    var isCurrentUser: Box<Bool?> = Box(nil)
    var userPosts = Box([PostModel]())
    var error: Box<Error?> = Box(nil)
    var needLogOut: (() -> Void)?
    
    var numberOfItems: Int {
        userPosts.value.count
    }
    
    /// Очередь для выстраивания запросов данных у провайдера.
    private let receiveDataQueue = DispatchQueue(label: "receiveDataQueue", qos: .userInteractive)
    /// Семафор для установки порядка запросов к провайдеру.
    private let semaphore = DispatchSemaphore(value: 1)
    private let keychainService: KeychainServiceProtocol = KeychainService()
    private let authorizationService: AuthorizationServiceProtocol = AuthorizationService.shared
    private let dataFetchingService: DataFetchingServiceProtocol = DataFetchingService.shared
    private let dataStorageService: DataStorageServiceProtocol = DataStorageService.shared
    private let offlineMode = AppError.offlineMode
    
    // MARK: - Initialization
    
    init(user: UserModel? = nil) {
        self.user = Box(user)
    }
    
    func getCurrentUser() {
        // Получение данных о текущем пользователе должно произойти до получения данных об открываемом профиле (которое происходит в методе getUser)
        receiveDataQueue.async { [weak self] in
            guard let self = self else { return }

            self.semaphore.wait()

            self.dataFetchingService.fetchCurrentUser() { result in
                switch result {
                case .success(let currentUser):
                    // Проверка того, открывается ли профиль текущего пользователя
                    if let userID = self.user.value?.id, userID != currentUser.id {
                        self.isCurrentUser.value = false
                    } else {
                        self.isCurrentUser.value = true
                        self.user.value = currentUser
                    }
                case .failure(let error):
                    self.error.value = error
                }
                self.semaphore.signal()
            }
        }
    }
    
    /// Получение данных об открываемом пользователе.
    func getUser() {
        LoadingView.show()
        
        receiveDataQueue.async { [weak self] in
            guard let self = self else { return }

            self.semaphore.wait()
            
            // Эта строка после семафора, потому что наличие user можно проверять только после окончания выполнения метода getCurrentUser()
            guard let user = self.user.value else {
                self.semaphore.signal()
                return
            }
            
            // Обновление данных о пользователе
            self.dataFetchingService.fetchUser(withID: user.id) { result in
                switch result {
                case .success(let user):
                    self.user.value = user
                    self.getUserPosts(of: user)
                case .failure(let error):
                    self.error.value = error
                }
                self.semaphore.signal()
            }
        }
    }
    
    func getCellData(at indexPath: IndexPath) -> Data {
        userPosts.value[indexPath.item].getImageData()
    }
    
    func logOutButtonDidTap() {
        authorizationService.singOut() { [weak self] result in
            switch result {
            case .success:
                self?.keychainService.removeToken()
                self?.dataStorageService.deleteAllData()
                self?.needLogOut?()
            case .failure(let error):
                self?.error.value = error
            }
        }
    }
    
    func getProfileHeaderViewModel(delegate: ProfileHeaderViewModelDelegate) -> ProfileHeaderViewModelProtocol? {
        guard let user = user.value, let isCurrentUser = isCurrentUser.value else { return nil }
        
        return ProfileHeaderViewModel(user: user, isCurrentUser: isCurrentUser, delegate: delegate)
    }
    
    func getUserListViewModel(withUserListType userListType: UserListType) -> UserListViewModelProtocol? {
        // Проверка, чтобы в оффлайн режиме не переходить по тапу кнопок "Followers" и "Followings"
        guard stopIfOffline() else { return nil }
        guard let user = user.value else { return nil }

        return UserListViewModel(userID: user.id, userListType: userListType)
    }
    
    func getAuthorizationViewModel() -> AuthorizationViewModelProtocol {
        AuthorizationViewModel()
    }
    
    // MARK: - Private methods
    
    /// Получение постов пользователя.
    private func getUserPosts(of user: UserModel) {
        dataFetchingService.fetchPostsOfUser(withID: user.id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let userPosts):
                self.userPosts.value = userPosts
                LoadingView.hide()
            case .failure(let error):
                self.error.value = error
            }
        }
    }
    
    /// Возвращает true, если онлайн режим. Возвращает false и инициирует соответствующее оповещение, если оффлайн режим.
    private func stopIfOffline() -> Bool {
        guard NetworkService.isOnline else {
            error.value = offlineMode
            return false
        }
        return true
    }
}
