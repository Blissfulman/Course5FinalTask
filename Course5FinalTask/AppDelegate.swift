//
//  AppDelegate.swift
//  Course5FinalTask
//
//  Copyright © 2018 e-Legion. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let authorizationCV = AuthorizationViewController()
        authorizationCV.viewModel = AuthorizationViewModel()
        window?.rootViewController = authorizationCV
        window?.makeKeyAndVisible()
        return true
    }
}

extension AppDelegate {
    static let storyboardName = "Main"
    
    static var shared: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
}
