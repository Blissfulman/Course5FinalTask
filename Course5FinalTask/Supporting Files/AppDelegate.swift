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
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let authorizationCV = AuthorizationViewController(viewModel: AuthorizationViewModel())
        window?.rootViewController = authorizationCV
        window?.makeKeyAndVisible()
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Т.к. в оффлайн режиме данные в CoreData изменяться не будут, то и сохранять их имеет смысл только в онлайн режиме
        if NetworkService.isOnline {
            let dataStorageService: DataStorageServiceProtocol = DataStorageService.shared
            dataStorageService.saveData()
        }
    }
}

extension AppDelegate {
    
    static var shared: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
}
