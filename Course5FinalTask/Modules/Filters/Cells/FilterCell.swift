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
    
    func configure(imageData: Data, filterName: String) {
        thumbnailImageView.image = UIImage(data: imageData)
        filterNameLabel.text = filterName
    }
}
