//
//  AuthorizationViewController.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 30.11.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class AuthorizationViewController: UIViewController {

    // MARK: - Properties
    
    var viewModel: AuthorizationViewModelProtocol!
    
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
        textField.addTarget(self, action: #selector(textFieldsDidChanged), for: .editingChanged)
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
        textField.addTarget(self, action: #selector(textFieldsDidChanged), for: .editingChanged)
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
        button.addTarget(self, action: #selector(signInButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private let appDelegate = AppDelegate.shared
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupUI()
        setupLayout()
        setupViewModelBinding()
    }
    
    // MARK: - Actions
    
    @objc func textFieldsDidChanged() {
        viewModel.login = loginTextField.text
        viewModel.password = passwordTextField.text
        
        signInButton.isEnabled = viewModel.isEnabledSignInButton
        signInButton.alpha = CGFloat(viewModel.signInButtonAlpha)
    }
    
    @objc private func signInButtonPressed() {
        view.endEditing(true)
        viewModel.authorizeUser()
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
            loginTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                constant: 30),
            loginTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                    constant: 16),
            loginTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                     constant: -16),
            loginTextField.heightAnchor.constraint(equalToConstant: 40),
            
            passwordTextField.topAnchor.constraint(equalTo: loginTextField.bottomAnchor,
                                                   constant: 8),
            passwordTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                       constant: 16),
            passwordTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                        constant: -16),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            signInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor,
                                              constant: 100),
            signInButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                  constant: 16),
            signInButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                   constant: -16),
            signInButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Private methods
    
    private func setupViewModelBinding() {
        viewModel.authorizationSuccess = { [weak self] in
            let storyboard = UIStoryboard(name: AppDelegate.storyboardName, bundle: nil)
            
            guard let tabBarController = storyboard.instantiateViewController(
                    withIdentifier: TabBarController.identifier
            ) as? TabBarController else { return }
            
            self?.appDelegate.window?.rootViewController = tabBarController
        }
        
        viewModel.error.bind { [weak self] error in
            guard let error = error else { return }
            self?.showAlert(error)
        }
    }
}

// MARK: - Text field delegate

extension AuthorizationViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == loginTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            signInButtonPressed()
        }
        return true
    }
}
