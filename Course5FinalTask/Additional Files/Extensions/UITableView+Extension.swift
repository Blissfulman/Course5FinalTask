//
//  UITableView+Extension.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 01.07.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import UIKit

extension UITableView {
    
    func register<Cell: UITableViewCell>(nibCell: Cell.Type) {
        register(Cell.nib(), forCellReuseIdentifier: Cell.identifier)
    }
}
