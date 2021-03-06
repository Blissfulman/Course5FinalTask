//
//  NewPhotoCell.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 03.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class NewPhotoCell: UICollectionViewCell {
    
    @IBOutlet private weak var photoImageView: UIImageView!
    
    func configure(_ imageData: Data) {
        photoImageView.image = UIImage(data: imageData)
    }
}
