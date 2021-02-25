//
//  UserListViewModel.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 10.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

// MARK: - Protocols

protocol UserListViewModelProtocol {
    var userList: Box<[UserModel]> { get }
    var error: Box<Error?> { get }
    var title: String? { get }
    var numberOfRows: Int { get }
    
    init(postID: String?, userID: String?, userListType: UserListType)
    
    func getUserImageData(at indexPath: IndexPath) -> Data?
    func getUserFullName(at indexPath: IndexPath) -> String?
    func getProfileViewModel(at indexPath: IndexPath) -> ProfileViewModelProtocol
    func updateUserList()
}

final class UserListViewModel: UserListViewModelProtocol {
    
    // MARK: - Properties
    
    var userList = Box([UserModel]())
    
    var error: Box<Error?> = Box(nil)
    
    var title: String? {
        userListType.rawValue
    }
    
    var numberOfRows: Int {
        userList.value.count
    }
    
    /// ID пользователя, подписчиков либо подписок которого, требуется отобразить.
    private let userID: String!
    
    /// ID поста, лайкнувших пользователей которого, требуется отобразить.
    private let postID: String!
    
    /// Тип списка отображаемых пользователей.
    private let userListType: UserListType
    
    private let networkService: NetworkServiceProtocol = NetworkService.shared
    
    // MARK: - Initializers
    
    init(postID: String? = nil, userID: String? = nil, userListType: UserListType) {
        self.userID = userID
        self.postID = postID
        self.userListType = userListType
    }
    
    // MARK: - Public methods
    
    func getUserImageData(at indexPath: IndexPath) -> Data? {
        let url = userList.value[indexPath.row].avatar
        return try? Data(contentsOf: url)
    }
    
    func getUserFullName(at indexPath: IndexPath) -> String? {
        userList.value[indexPath.row].fullName
    }
    
    func getProfileViewModel(at indexPath: IndexPath) -> ProfileViewModelProtocol {
        let user = userList.value[indexPath.row]
        return ProfileViewModel(user: user)
    }
    
    func updateUserList() {
        
        LoadingView.show()
        
        /// Замыкание, в котором обновляется список отображаемых пользователей, либо вернувшаяся ошибка.
        let updatingUserList: UsersResult = { [weak self] result in
            switch result {
            case .success(let userList):
                self?.userList.value = userList
                LoadingView.hide()
            case .failure(let error):
                self?.error.value = error
            }
        }
        
        switch userListType {
        case .likes:
            networkService.fetchUsersLikedPost(withID: postID, completion: updatingUserList)
        case .followers:
            networkService.fetchUsersFollowingUser(withID: userID, completion: updatingUserList)
        case .followings:
            networkService.fetchUsersFollowedByUser(withID: userID, completion: updatingUserList)
        }
    }
}
