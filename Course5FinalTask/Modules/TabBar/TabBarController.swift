//
//  TabBarController.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 01.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class TabBarController: UITabBarController {
    
    static let identifier = String(describing: TabBarController.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabs()
    }
    
    private func setupTabs() {
        let feedVC = FeedViewController(nibName: nil, bundle: nil)
        feedVC.title = "Feed"
        let firstTabBarVC = UINavigationController(rootViewController: feedVC)
        firstTabBarVC.tabBarItem.image = UIImage(named: "feed")
        
        let newPostVC = NewPostViewController(nibName: nil, bundle: nil)
        newPostVC.title = "New post"
        let secondTabBarVC = UINavigationController(rootViewController: newPostVC)
        secondTabBarVC.tabBarItem.image = UIImage(named: "plus")
        
        let profileVC = ProfileViewController(nibName: nil, bundle: nil)
        profileVC.title = "Profile"
        let thirdTabBarVC = UINavigationController(rootViewController: profileVC)
        thirdTabBarVC.tabBarItem.image = UIImage(named: "profile")
        
        viewControllers = [firstTabBarVC, secondTabBarVC, thirdTabBarVC]
    }
}
