//
//  ProfileHeaderViewModel.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 20.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

// MARK: - Protocols

protocol ProfileHeaderViewModelDelegate: AnyObject {
    func followersButtonTapped()
    func followingsButtonTapped()
    func showErrorAlert(_ error: Error)
}

protocol ProfileHeaderViewModelProtocol: AnyObject {
    var delegate: ProfileHeaderViewModelDelegate? { get }
    var user: Box<UserModel> { get }
    var avatarImageData: Data { get }
    var userFullName: String { get }
    var isHiddenFollowButton: Bool { get }
    var followButtonTitle: String { get }
    var followersButtonTitle: String { get }
    var followingsButtonTitle: String { get }
    
    init(user: UserModel, isCurrentUser: Bool, delegate: ProfileHeaderViewModelDelegate)
    
    func followButtonTapped()
    func followersButtonTapped()
    func followingsButtonTapped()
}

final class ProfileHeaderViewModel: ProfileHeaderViewModelProtocol {
    
    // MARK: - Properties
    
    weak var delegate: ProfileHeaderViewModelDelegate?
    var user: Box<UserModel>
    
    var avatarImageData: Data {
        user.value.getAvatarData()
    }
    
    var userFullName: String {
        user.value.fullName
    }
    
    var isHiddenFollowButton: Bool {
        isCurrentUser
    }
    
    var followButtonTitle: String {
        user.value.currentUserFollowsThisUser ? "Unfollow".localized() : "Follow".localized()
    }
    
    var followersButtonTitle: String {
        "Followers: ".localized() + String(user.value.followedByCount)
    }
    
    var followingsButtonTitle: String {
        "Followings: ".localized() + String(user.value.followsCount)
    }
    
    private let isCurrentUser: Bool
    private let dataFetchingService: DataFetchingServiceProtocol = DataFetchingService.shared
    
    // MARK: - Initialization
    
    init(user: UserModel, isCurrentUser: Bool, delegate: ProfileHeaderViewModelDelegate) {
        self.user = Box(user)
        self.isCurrentUser = isCurrentUser
        self.delegate = delegate
    }
    
    // MARK: - Public methods
    
    func followButtonTapped() {
        /// Замыкание, в котором обновляются данные о пользователе.
        let updatingUser: UserResult = { [weak self] result in
            switch result {
            case .success(let updatedUser):
                self?.user.value = updatedUser
            case .failure(let error):
                self?.delegate?.showErrorAlert(error)
            }
        }
        
        // Подписка/отписка
        user.value.currentUserFollowsThisUser
            ? dataFetchingService.unfollowFromUser(withID: user.value.id, completion: updatingUser)
            : dataFetchingService.followToUser(withID: user.value.id, completion: updatingUser)
    }
    
    func followersButtonTapped() {
        delegate?.followersButtonTapped()
    }
    
    func followingsButtonTapped() {
        delegate?.followingsButtonTapped()
    }
}
