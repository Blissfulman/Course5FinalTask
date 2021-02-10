//
//  ProfileCollectionViewCell.swift
//  Course5FinalTask
//
//  Created by User on 07.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class ProfileCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    
    static let identifier = "photoCell"
    
    static func nib() -> UINib {
        UINib(nibName: "ProfileCollectionViewCell", bundle: nil)
    }
    
    func configure(_ post: Post) {
        photoImage.getImage(fromURL: post.image)
    }
}
