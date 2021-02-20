//
//  ProfileHeaderViewModel.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 20.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

// MARK: - Protocols

protocol ProfileHeaderViewModelProtocol {
    var user: Box<UserModel> { get }
    var error: Box<Error?> { get }
    var avatarImageData: Data { get }
    var userFullName: String { get }
    var isHiddenFollowButton: Bool { get }
    var followButtonTitle: String { get }
    var followersButtonTitle: String { get }
    var followingsButtonTitle: String { get }
    
    init(user: UserModel, isCurrentUser: Bool)
    
    func followButtonDidTapped()
}

final class ProfileHeaderViewModel: ProfileHeaderViewModelProtocol {
    
    // MARK: - Properties
    
    var user: Box<UserModel>
    var error: Box<Error?> = Box(nil)
    
    var avatarImageData: Data {
        networkService.getImageData(fromURL: user.value.avatar) ?? Data()
    }
    
    var userFullName: String {
        user.value.fullName
    }
    
    var isHiddenFollowButton: Bool {
        isCurrentUser
    }
    
    var followButtonTitle: String {
        user.value.currentUserFollowsThisUser ? "Unfollow" : "Follow"
    }
    
    var followersButtonTitle: String {
        "Followers: " + String(user.value.followedByCount)
    }
    
    var followingsButtonTitle: String {
        "Followings: " + String(user.value.followsCount)
    }
    
    private let isCurrentUser: Bool
    private let networkService: NetworkServiceProtocol = NetworkService.shared
    
    // MARK: - Initializers
    
    init(user: UserModel, isCurrentUser: Bool) {
        self.user = Box(user)
        self.isCurrentUser = isCurrentUser
    }
    
    // MARK: - Public methods
    
    func followButtonDidTapped() {
        /// Замыкание, в котором обновляются данные о пользователе.
        let updatingUser: UserResult = { [weak self] result in
            switch result {
            case .success(let updatedUser):
                self?.user.value = updatedUser
            case .failure(let error):
                self?.error.value = error
            }
        }
        
        // Подписка/отписка
        user.value.currentUserFollowsThisUser
            ? networkService.unfollowFromUser(withID: user.value.id, completion: updatingUser)
            : networkService.followToUser(withID: user.value.id, completion: updatingUser)
    }
}
