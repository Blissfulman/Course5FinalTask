//
//  FilterCell.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 04.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class FilterCell: UICollectionViewCell {

    @IBOutlet private weak var thumbnailImageView: UIImageView!
    @IBOutlet private weak var filterNameLabel: UILabel!
    
    static let identifier = String(describing: FilterCell.self)
    
    static func nib() -> UINib {
        UINib(nibName: identifier, bundle: nil)
    }
    
    func configure(photo: UIImage, filterName: String) {
        thumbnailImageView.image = photo
        filterNameLabel.text = filterName
    }
}
