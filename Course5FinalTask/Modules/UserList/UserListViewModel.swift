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
    
    init(postID: PostModel.ID?, userID: UserModel.ID?, userListType: UserListType)
    
    func getUserImageData(at indexPath: IndexPath) -> Data
    func getUserFullName(at indexPath: IndexPath) -> String?
    func getProfileViewModel(at indexPath: IndexPath) -> ProfileViewModelProtocol
    func updateUserList()
}

final class UserListViewModel: UserListViewModelProtocol {
    
    // MARK: - Properties
    
    var userList = Box([UserModel]())
    var error: Box<Error?> = Box(nil)
    
    var title: String? {
        userListType.title
    }
    
    var numberOfRows: Int {
        userList.value.count
    }
    
    /// ID пользователя, подписчиков либо подписок которого, требуется отобразить.
    private let userID: UserModel.ID!
    /// ID поста, лайкнувших пользователей которого, требуется отобразить.
    private let postID: PostModel.ID!
    /// Тип списка отображаемых пользователей.
    private let userListType: UserListType
    private let dataFetchingService: DataFetchingServiceProtocol = DataFetchingService.shared
    
    // MARK: - Initializers
    
    init(postID: PostModel.ID? = nil, userID: UserModel.ID? = nil, userListType: UserListType) {
        self.userID = userID
        self.postID = postID
        self.userListType = userListType
    }
    
    // MARK: - Public methods
    
    func getUserImageData(at indexPath: IndexPath) -> Data {
        userList.value[indexPath.row].getAvatarData()
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
        
        /// Замыкание, в котором обновляется список отображаемых пользователей.
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
            dataFetchingService.fetchUsersLikedPost(withID: postID, completion: updatingUserList)
        case .followers:
            dataFetchingService.fetchUsersFollowingUser(withID: userID, completion: updatingUserList)
        case .followings:
            dataFetchingService.fetchUsersFollowedByUser(withID: userID, completion: updatingUserList)
        }
    }
}
