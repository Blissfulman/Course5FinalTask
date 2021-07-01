//
//  UICollectionView+Extension.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 01.07.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    func register<Cell: UICollectionReusableView>(nibCell: Cell.Type) {
        register(Cell.nib(), forCellWithReuseIdentifier: Cell.identifier)
    }
}
