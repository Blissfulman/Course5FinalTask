//
//  ProfilePhotoCell.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 07.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class ProfilePhotoCell: UICollectionViewCell {
    
    static let identifier = String(describing: ProfilePhotoCell.self)
    
    static func nib() -> UINib {
        UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet private weak var photoImageView: UIImageView!
    
    func configure(_ imageData: Data) {
        photoImageView.image = UIImage(data: imageData)
    }
}
