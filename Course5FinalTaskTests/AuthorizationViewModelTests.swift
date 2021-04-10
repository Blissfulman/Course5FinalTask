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
    
    var sut: AuthorizationViewModelProtocol!
    
    override func setUp() {
        super.setUp()
        sut = AuthorizationViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testIsEnabledSignInButtonShouldBeFalseIfLoginIsEmpty() {
        sut.login = ""
        sut.password = "1"
        XCTAssertFalse(sut.isEnabledSignInButton)
    }
    
    func testIsEnabledSignInButtonShouldBeFalseIfPasswordIsEmpty() {
        sut.login = "1"
        sut.password = ""
        XCTAssertFalse(sut.isEnabledSignInButton)
    }
    
    func testIsEnabledSignInButtonShouldBeTrueIfLoginAndPasswordIsNotEmpty() {
        sut.login = "1"
        sut.password = "1"
        XCTAssertTrue(sut.isEnabledSignInButton)
    }
}
