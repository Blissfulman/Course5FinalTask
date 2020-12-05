//
//  NewPostCollectionViewCell.swift
//  Course4FinalTask
//
//  Created by User on 03.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class NewPostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    
    static let identifier = "newPhotoCell"
    
    weak var delegate: HeaderProfileCollectionViewDelegate?
    
    static func nib() -> UINib {
        return UINib(nibName: "NewPostCollectionViewCell", bundle: nil)
    }
    
    func configure(_ photo: UIImage) {
        photoImage.image = photo
    }
}
