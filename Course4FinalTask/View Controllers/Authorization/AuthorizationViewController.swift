//
//  AuthorizationViewController.swift
//  Course4FinalTask
//
//  Created by User on 30.11.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class AuthorizationViewController: UIViewController {

    // MARK: - Properties
    private lazy var loginTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "login"
        textField.textContentType = .username
        textField.keyboardType = .emailAddress
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 14)
        textField.autocapitalizationType = .none
        textField.returnKeyType = .next
        textField.enablesReturnKeyAutomatically = true
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self,
                            action: #selector(textFieldsDidChanged),
                            for: .editingChanged)
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "password"
        textField.textContentType = .password
        textField.keyboardType = .asciiCapable
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 14)
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.returnKeyType = .send
        textField.enablesReturnKeyAutomatically = true
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self,
                            action: #selector(textFieldsDidChanged),
                            for: .editingChanged)
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
        button.addTarget(self,
                         action: #selector(signInButtonPressed),
                         for: .touchUpInside)
        return button
    }()
    
    private let appDelegate = AppDelegate.shared
    private let networkService: NetworkServiceProtocol = NetworkService.shared

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupUI()
        setupLayout()
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - Private methods
    private func authorizeUser(login: String, password: String) {
        
        networkService.singIn(login: login, password: password) {
            [weak self] result in
            
            switch result {
            case let .success(token):
                
                DispatchQueue.main.async {
                    
                    let storyboard = UIStoryboard(name: AppDelegate.storyboardName,
                                                  bundle: nil)
                    
                    guard let tabBarController = storyboard.instantiateViewController(withIdentifier: TabBarController.identifier) as? TabBarController else { return }
                    
                    NetworkService.token = token.token
                    self?.appDelegate.window?.rootViewController = tabBarController
                }
            case let .failure(error):
                self?.showAlert(error)
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
