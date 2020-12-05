//
//  FiltersCollectionViewCell.swift
//  Course4FinalTask
//
//  Created by User on 04.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class FiltersCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var filterNameLabel: UILabel!
    
    static let identifier = "filtersPhotoCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "FiltersCollectionViewCell", bundle: nil)
    }
    
    func configure(photo: UIImage, filterName: String) {
        thumbnailImageView.image = photo
        filterNameLabel.text = filterName
    }

}
