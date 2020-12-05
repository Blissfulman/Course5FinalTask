//
//  PhotoCollectionViewCell.swift
//  Course4FinalTask
//
//  Created by User on 07.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class ProfileCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    
    static let identifier = "photoCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "ProfileCollectionViewCell", bundle: nil)
    }
    
    func configure(_ photo: UIImage) {
        photoImage.image = photo
    }
}
