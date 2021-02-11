//
//  UserListViewModel.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 10.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

protocol UserListViewModelProtocol {
    
    /// Список отображаемых в таблице пользователей.
    var userList: Box<[User]> { get }
    
    /// Получаемая от сервера ошибка.
    var error: Box<Error?> { get }
    
    var title: String? { get }
    var numberOfRows: Int { get }
    
    init(postID: String?, userID: String?, userListType: UserListType)
    
    func getUserImageData(atIndexPath: IndexPath) -> Data?
    func getUserFullName(atIndexPath: IndexPath) -> String?
    func getUser(atIndexPath: IndexPath) -> User
    func updateUserList()
}

final class UserListViewModel: UserListViewModelProtocol {
    
    // MARK: - Properties
    
    var userList = Box([User]())
    
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
    
    func getUserImageData(atIndexPath indexPath: IndexPath) -> Data? {
        let url = userList.value[indexPath.row].avatar
        return try? Data(contentsOf: url)
    }
    
    func getUserFullName(atIndexPath indexPath: IndexPath) -> String? {
        userList.value[indexPath.row].fullName
    }
    
    func getUser(atIndexPath indexPath: IndexPath) -> User {
        userList.value[indexPath.row]
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
            networkService.getUsersLikedPost(withID: postID, completion: updatingUserList)
        case .followers:
            networkService.getUsersFollowingUser(withID: userID, completion: updatingUserList)
        case .following:
            networkService.getUsersFollowedByUser(withID: userID, completion: updatingUserList)
        }
    }
}
