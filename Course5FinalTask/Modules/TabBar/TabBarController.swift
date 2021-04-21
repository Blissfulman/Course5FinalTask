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
    
    // MARK: - Static properties
    
    static let identifier = String(describing: TabBarController.self)
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTabs()
    }
    
    // MARK: - Private methods
    
    private func configureTabs() {
        let feedVC = FeedViewController(viewModel: FeedViewModel())
        feedVC.title = Titles.feed
        let firstTabBarVC = UINavigationController(rootViewController: feedVC)
        firstTabBarVC.tabBarItem.image = UIImage(named: Images.feed)
        
        let newPostVC = NewPostViewController()
        newPostVC.title = Titles.newPost
        let secondTabBarVC = UINavigationController(rootViewController: newPostVC)
        secondTabBarVC.tabBarItem.image = UIImage(named: Images.newPost)
        
        let profileVC = ProfileViewController(viewModel: ProfileViewModel())
        profileVC.title = Titles.profile
        let thirdTabBarVC = UINavigationController(rootViewController: profileVC)
        thirdTabBarVC.tabBarItem.image = UIImage(named: Images.profile)
        
        viewControllers = [firstTabBarVC, secondTabBarVC, thirdTabBarVC]
    }
}
