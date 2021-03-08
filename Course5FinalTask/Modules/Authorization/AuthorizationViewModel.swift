//
//  AuthorizationViewModel.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 12.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

protocol AuthorizationViewModelProtocol {
    var login: String? { get set }
    var password: String? { get set }
    var isEnabledSignInButton: Bool { get }
    var signInButtonAlpha: Float { get }
    var authorizationSuccess: (() -> Void)? { get set }
    var error: Box<Error?> { get }
    
    func checkAuthorization()
    func authorizeUser()
}

final class AuthorizationViewModel: AuthorizationViewModelProtocol {
    
    // MARK: - Properties
    
    var login: String?
    
    var password: String?
    
    var isEnabledSignInButton: Bool {
        guard let login = login, !login.isEmpty, let password = password, !password.isEmpty else {
            return false
        }
        return true
    }
    
    var signInButtonAlpha: Float {
        isEnabledSignInButton ? 1 : 0.3
    }
    
    var authorizationSuccess: (() -> Void)?
    
    var error: Box<Error?> = Box(nil)
    
    private let keychainService: KeychainServiceProtocol = KeychainService()
    private let networkService: NetworkServiceProtocol = NetworkService.shared
    
    // MARK: - Public methods
    
    func checkAuthorization() {
        if let _ = keychainService.getToken() {
            LoadingView.show()
            
            networkService.checkToken { [weak self] result in
                LoadingView.hide()
                
                switch result {
                case .success:
                    print("Token is valid")
                    self?.authorizationSuccess?()
                case .failure(let error):
                    let _ = self?.keychainService.removeToken()
                    self?.error.value = error
                }
            }
        }
    }
    
    func authorizeUser() {
        guard let login = login, let password = password else { return }
        
        networkService.singIn(login: login, password: password) { [weak self] result in
            switch result {
            case .success(let tokenModel):
                let _ = self?.keychainService.saveToken(tokenModel)
                self?.authorizationSuccess?()
            case .failure(let error):
                self?.error.value = error
            }
        }
    }
}
