//
//  ProfileViewController.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 04.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var profileCollectionView: UICollectionView!
    
    // MARK: - Properties
    
    var viewModel: ProfileViewModelProtocol
    
    // MARK: - Initialization
    
    init(viewModel: ProfileViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifeсycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileCollectionView.register(
            ProfileHeaderView.nib(),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ProfileHeaderView.identifier
        )
        profileCollectionView.register(nibCell: ProfilePhotoCell.self)
        viewModel.getCurrentUser()
        setupViewModelBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.getUser()
    }
    
    // MARK: - Actions
    
    @objc private func logOutButtonTapped() {
        viewModel.logOutButtonDidTap()
    }
    
    // MARK: - Private methods
        
    private func setupViewModelBindings() {
        viewModel.user.bind { [unowned self] user in
            navigationItem.title = user?.username
            profileCollectionView.reloadData()
        }
        
        viewModel.isCurrentUser.bind { [unowned self] isCurrentUser in
            if let isCurrentUser = isCurrentUser, isCurrentUser {
                addLogOutButton()
            }
        }
        
        viewModel.userPosts.bind { [unowned self] _ in
            profileCollectionView.reloadData()
        }
        
        viewModel.error.bind { [unowned self] error in
            guard let error = error else { return }
            showAlert(error)
        }
        
        viewModel.needLogOut = { [unowned self] in
            DispatchQueue.main.async {
                let authorizationVC = AuthorizationViewController(viewModel: viewModel.getAuthorizationViewModel())
                AppDelegate.shared.window?.rootViewController = authorizationVC
            }
        }
    }
    
    private func addLogOutButton() {
        let logOutButton = UIBarButtonItem(
            title: "Log out".localized(), style: .plain, target: self, action: #selector(logOutButtonTapped)
        )
        navigationItem.rightBarButtonItem = logOutButton
    }
}

// MARK: - Сollection view data source

extension ProfileViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = profileCollectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: ProfileHeaderView.identifier,
                for: indexPath
            ) as! ProfileHeaderView
                        
            if let profileHeaderViewModel = viewModel.getProfileHeaderViewModel(delegate: self) {
                header.viewModel = profileHeaderViewModel
            }
            return header
        default:
            fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let cell = profileCollectionView.dequeueReusableCell(
            withReuseIdentifier: ProfilePhotoCell.identifier, for: indexPath
        ) as! ProfilePhotoCell
        
        cell.configure(viewModel.getCellData(at: indexPath))
        return cell
    }
}

// MARK: - Collection view layout

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
    private var numberOfColumns: CGFloat { 3 }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: profileCollectionView.frame.width, height: UIConstants.profileHeaderHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let size = profileCollectionView.frame.width / numberOfColumns
        return CGSize(width: size, height: size)
    }
}

// MARK: - ProfileHeaderViewModelDelegate

extension ProfileViewController: ProfileHeaderViewModelDelegate {
    
    // MARK: - Navigation
    
    /// Переход на подписчиков пользователя.
    func followersButtonTapped() {
        guard let userListVM = viewModel.getUserListViewModel(withUserListType: .followers) else { return }
        
        let followersVC = UserListViewController(viewModel: userListVM)
        navigationController?.pushViewController(followersVC, animated: true)
    }

    /// Переход на подписки пользователя.
    func followingsButtonTapped() {
        guard let userListVM = viewModel.getUserListViewModel(withUserListType: .followings) else { return }
        
        let followingVC = UserListViewController(viewModel: userListVM)
        navigationController?.pushViewController(followingVC, animated: true)
    }
    
    func showErrorAlert(_ error: Error) {
        self.showAlert(error)
    }
}
