//
//  Box.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 11.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

final class Box<T> {
    
    typealias Listener = ((T) -> Void)
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    var listener: Listener?
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(listener: @escaping Listener) {
        self.listener = listener
        listener(value)
    }
}
