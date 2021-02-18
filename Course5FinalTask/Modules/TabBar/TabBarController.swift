//
//  TabBarController.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 01.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - Nested types
    
    private enum Titles {
        static let feed = "Feed"
        static let newPost = "New post"
        static let profile = "Profile"
    }
    
    private enum Images {
        static let feed = "feed"
        static let newPost = "plus"
        static let profile = "profile"
    }
    
    // MARK: - Properties
    
    static let identifier = String(describing: TabBarController.self)
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabs()
    }
    
    // MARK: - Private methods
    
    private func setupTabs() {
        let feedVC = FeedViewController(nibName: nil, bundle: nil)
        feedVC.title = Titles.feed
        let firstTabBarVC = UINavigationController(rootViewController: feedVC)
        firstTabBarVC.tabBarItem.image = UIImage(named: Images.feed)
        
        let newPostVC = NewPostViewController(nibName: nil, bundle: nil)
        newPostVC.title = Titles.newPost
        let secondTabBarVC = UINavigationController(rootViewController: newPostVC)
        secondTabBarVC.tabBarItem.image = UIImage(named: Images.newPost)
        
        let profileVC = ProfileViewController(nibName: nil, bundle: nil)
        profileVC.title = Titles.profile
        let thirdTabBarVC = UINavigationController(rootViewController: profileVC)
        thirdTabBarVC.tabBarItem.image = UIImage(named: Images.profile)
        
        viewControllers = [firstTabBarVC, secondTabBarVC, thirdTabBarVC]
    }
}
