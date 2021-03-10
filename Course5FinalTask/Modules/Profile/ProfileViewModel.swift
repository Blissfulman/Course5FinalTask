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
    
    var numberOfItems: Int {
        userPosts.value.count
    }
    
    /// Очередь для выстраивания запросов данных у провайдера.
    private let getDataQueue = DispatchQueue(label: "getDataQueue", qos: .userInteractive)
    
    /// Семафор для установки порядка запросов к провайдеру.
    private let semaphore = DispatchSemaphore(value: 1)
    
    private let keychainService: KeychainServiceProtocol = KeychainService()
    private let authorizationService: AuthorizationServiceProtocol = AuthorizationService.shared
    private let dataService: DataServiceProtocol = DataService.shared
    
    // MARK: - Initializers
    
    init(user: UserModel? = nil) {
        self.user = Box(user)
    }
    
    func getCurrentUser() {
        // Получение данных о текущем пользователе должно произойти до получения данных об открываемом профиле (которое происходит в методе getUser)
        getDataQueue.async { [weak self] in
            
            guard let self = self else { return }

            self.semaphore.wait()

            self.dataService.fetchCurrentUser() { result in
                switch result {
                case .success(let currentUser):
                    // Проверка того, открывается ли профиль текущего пользователя
                    if let userID = self.user.value?.id, userID != currentUser.id {
                        self.isCurrentUser.value = false
                    } else {
                        self.isCurrentUser.value = true
                        self.user.value = currentUser
                    }
                    self.semaphore.signal()
                case .failure(let error):
                    self.error.value = error
                    self.semaphore.signal()
                }
            }
        }
    }
    
    /// Получение данных об открываемом пользователе.
    func getUser() {
        LoadingView.show()
        
        getDataQueue.async { [weak self] in
            
            guard let self = self else { return }

            self.semaphore.wait()
            
            // Эта строка после семафора, потому что наличие user можно проверять только после окончания выполнения функции getCurrentUser()
            guard let user = self.user.value else { return }
            
            // Обновление данных о пользователе
            self.dataService.fetchUser(withID: user.id) { result in
                switch result {
                case .success(let user):
                    self.user.value = user
                    self.semaphore.signal()
                    
                    // Обновление данных об изображениях постов пользователя
                    self.getUserPosts(of: user)
                case .failure(let error):
                    self.error.value = error
                    self.semaphore.signal()
                }
            }
        }
    }
    
    func getCellData(at indexPath: IndexPath) -> Data {
        userPosts.value[indexPath.item].image.fetchPNGImageData()
    }
    
    func logOutButtonDidTap() {
        authorizationService.singOut() { [weak self] result in
            switch result {
            case .success:
                self?.keychainService.removeToken()
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
        guard let user = user.value else { return nil }

        return UserListViewModel(userID: user.id, userListType: userListType)
    }
    
    func getAuthorizationViewModel() -> AuthorizationViewModelProtocol {
        AuthorizationViewModel()
    }
    
    // MARK: - Private methods
    
    /// Получение постов пользователя.
    private func getUserPosts(of user: UserModel) {
        dataService.fetchPostsOfUser(withID: user.id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let userPosts):
                self.userPosts.value = userPosts.reversed()
                LoadingView.hide()
            case .failure(let error):
                self.error.value = error
            }
        }
    }
}
