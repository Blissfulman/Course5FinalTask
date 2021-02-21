//
//  ProfileViewController.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 04.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Class properties
    
    static let identifier = String(describing: ProfileViewController.self)
    
    // MARK: - Outlets
    
    @IBOutlet private weak var profileCollectionView: UICollectionView!
    
    // MARK: - Properties
    
    var viewModel: ProfileViewModelProtocol

    /// Количество колонок в представлении фотографий.
    private let numberOfColumns: CGFloat = 3
    
    // MARK: - Initializers
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, viewModel: ProfileViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
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
        profileCollectionView.register(ProfilePhotoCell.nib(),
                                       forCellWithReuseIdentifier: ProfilePhotoCell.identifier)
        viewModel.getCurrentUser()
        setupViewModelBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.getUser()
    }
    
    // MARK: - Actions
    
    @objc private func logOutButtonTapped() {
        viewModel.logOutButtonTapped()

        let authorizationVC = AuthorizationViewController(viewModel: viewModel.getAuthorizationViewModel())
        AppDelegate.shared.window?.rootViewController = authorizationVC
    }
    
    // MARK: - Private methods
        
    private func setupViewModelBindings() {
        viewModel.user.bind { [weak self] user in
            self?.navigationItem.title = user?.username
            self?.profileCollectionView.reloadData()
        }
        
        viewModel.isCurrentUser.bind { [weak self] isCurrentUser in
            if let isCurrentUser = isCurrentUser, isCurrentUser {
                self?.addLogOutButton()
            }
        }
        
        viewModel.userPosts.bind { [weak self] _ in
            self?.profileCollectionView.reloadData()
        }
        
        viewModel.error.bind { [weak self] error in
            guard let error = error else { return }
            self?.showAlert(error)
        }
    }
    
    private func addLogOutButton() {
        let logOutButton = UIBarButtonItem(
            title: "Log Out", style: .plain, target: self, action: #selector(logOutButtonTapped)
        )
        navigationItem.rightBarButtonItem = logOutButton
    }
}

// MARK: - Сollection view data source

extension ProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = profileCollectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: ProfileHeaderView.identifier,
                for: indexPath
            ) as! ProfileHeaderView
            
            header.delegate = self
            
            if let profileHeaderViewModel = viewModel.getProfileHeaderViewModel() {
                header.viewModel = profileHeaderViewModel
            }
            return header
        default: fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = profileCollectionView.dequeueReusableCell(
            withReuseIdentifier: ProfilePhotoCell.identifier, for: indexPath
        ) as! ProfilePhotoCell
        
        cell.configure(viewModel.getCellData(at: indexPath))
        return cell
    }
}

// MARK: - Collection view layout

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: profileCollectionView.frame.width, height: UIConstants.profileHeaderHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = profileCollectionView.frame.width / numberOfColumns
        return CGSize(width: size, height: size)
    }
}

// MARK: - ProfileHeaderViewDelegate

extension ProfileViewController: ProfileHeaderViewDelegate {
    
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
