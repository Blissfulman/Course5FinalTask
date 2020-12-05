//
//  AuthorizationViewController.swift
//  Course4FinalTask
//
//  Created by User on 30.11.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class AuthorizationViewController: UIViewController {

    // MARK: - Properties
    private lazy var loginTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "login"
        textField.textContentType = .username
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 14)
        textField.autocapitalizationType = .none
        textField.returnKeyType = .next
        textField.enablesReturnKeyAutomatically = true
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "password"
        textField.textContentType = .password
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 14)
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.returnKeyType = .send
        textField.enablesReturnKeyAutomatically = true
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.alpha = 0.3
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var token: String?
//    private let networkService: NetworkServiceProtocol = NetworkService()
        
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupUI()
        setupLayout()
        setupTargets()
        
//        AuthenticationService().authenticateUser() { [weak self] in
//
//            guard let `self` = self else { return }
//
//            guard let keychainData = KeychainStorage().getData() else { return }
//
//            self.authorizeUser(username: keychainData.username,
//                               password: keychainData.password)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.navigationBar.isHidden = true
//        usernameTextField.text = nil
//        passwordTextField.text = nil
    }
    
    // MARK: - Actions
    @objc func textFieldsDidChanged() {
        guard let login = loginTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        signInButton.isEnabled = !login.isEmpty && !password.isEmpty
        signInButton.alpha = signInButton.isEnabled ? 1 : 0.3
    }
    
    @objc private func signInButtonPressed() {
        
        view.endEditing(true)
        
        guard let login = loginTextField.text,
              let password = passwordTextField.text
        else { return }
        
        authorizeUser(login: login, password: password)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(loginTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signInButton)
        signInButton.layer.cornerRadius = 5
    }
    
    // MARK: - Setup layout
    private func setupLayout() {
        NSLayoutConstraint.activate([
            loginTextField.topAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                            constant: 30),
            loginTextField.leadingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                            constant: 16),
            loginTextField.trailingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                            constant: -16),
            loginTextField.heightAnchor.constraint(equalToConstant: 40),
            
            passwordTextField.topAnchor
                .constraint(equalTo: loginTextField.bottomAnchor,
                            constant: 8),
            passwordTextField.leadingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                            constant: 16),
            passwordTextField.trailingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                            constant: -16),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            signInButton.topAnchor
                .constraint(equalTo: passwordTextField.bottomAnchor,
                            constant: 100),
            signInButton.leadingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                            constant: 16),
            signInButton.trailingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                            constant: -16),
            signInButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupTargets() {
        loginTextField.addTarget(self,
                                    action: #selector(textFieldsDidChanged),
                                    for: .editingChanged)
        
        passwordTextField.addTarget(self,
                                    action: #selector(textFieldsDidChanged),
                                    for: .editingChanged)
        
        signInButton.addTarget(self,
                              action: #selector(signInButtonPressed),
                              for: .touchUpInside)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - Private methods
    private func authorizeUser(login: String, password: String) {

        NetworkService().singIn(login: login, password: password) {
            [weak self] token in
            
            guard let token = token?.token else {
                print("No token")
                return
            }
            
            self?.token = token
            print("Token:", token)
            
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: AppDelegate.storyboardName,
                                              bundle: nil)
                
                guard let tabBarController = storyboard.instantiateViewController(withIdentifier: TabBarController.identifier) as? TabBarController else { return }
                
                AppDelegate.token = token
                tabBarController.modalPresentationStyle = .fullScreen
                self?.show(tabBarController, sender: nil)
            }
        }
    }
}

// MARK: - TextFieldDelegate
extension AuthorizationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == loginTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            signInButtonPressed()
        }
        return true
    }
}
