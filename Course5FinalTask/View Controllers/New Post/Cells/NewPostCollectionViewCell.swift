//
//  NewPostCollectionViewCell.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 03.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class NewPostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var photoImageView: UIImageView!
    
    static let identifier = "newPhotoCell"
    
    weak var delegate: ProfileHeaderDelegate?
    
    static func nib() -> UINib {
        UINib(nibName: "NewPostCollectionViewCell", bundle: nil)
    }
    
    func configure(_ photo: UIImage) {
        photoImageView.image = photo
    }
}
