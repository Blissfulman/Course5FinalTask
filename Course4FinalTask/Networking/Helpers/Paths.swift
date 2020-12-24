//
//  Paths.swift
//  Course4FinalTask
//
//  Created by User on 01.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

enum TokenPath {
    static let signIn = "/signin"
    static let signOut = "/signout"
    static let check = "/checkToken"
}

enum UserPath {
    static let users = "/users/"
    static let currentUser = "/users/me"
    static let follow = "/users/follow"
    static let unfollow = "/users/unfollow"
    static let followers = "/followers"
    static let following = "/following"
}

enum PostPath {
    static let feed = "/posts/feed"
    static let posts = "/posts/"
    static let like = "/posts/like"
    static let unlike = "/posts/unlike"
    static let likes = "/likes"
    static let create = "/posts/create"
}
