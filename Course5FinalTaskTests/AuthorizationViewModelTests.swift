//
//  AuthorizationViewModelTests.swift
//  Course5FinalTaskTests
//
//  Created by Evgeny Novgorodov on 10.04.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import XCTest
@testable import Course5FinalTask

final class AuthorizationViewModelTests: XCTestCase {
    
    var authorizationViewModel: AuthorizationViewModelProtocol!
    
    override func setUp() {
        super.setUp()
        authorizationViewModel = AuthorizationViewModel()
    }
    
    override func tearDown() {
        authorizationViewModel = nil
        super.tearDown()
    }
    
    func testIsEnabledSignInButtonShouldBeFalseIfLoginAndPasswordIsEmpty() {
        authorizationViewModel.login = ""
        authorizationViewModel.password = ""
        XCTAssertFalse(authorizationViewModel.isEnabledSignInButton)
    }
    
    func testIsEnabledSignInButtonShouldBeFalseIfLoginIsEmpty() {
        authorizationViewModel.login = ""
        authorizationViewModel.password = "test"
        XCTAssertFalse(authorizationViewModel.isEnabledSignInButton)
    }
    
    func testIsEnabledSignInButtonShouldBeFalseIfPasswordIsEmpty() {
        authorizationViewModel.login = "test"
        authorizationViewModel.password = ""
        XCTAssertFalse(authorizationViewModel.isEnabledSignInButton)
    }
    
    func testIsEnabledSignInButtonShouldBeTrueIfLoginAndPasswordIsNotEmpty() {
        authorizationViewModel.login = "test"
        authorizationViewModel.password = "test"
        XCTAssertTrue(authorizationViewModel.isEnabledSignInButton)
    }
}
