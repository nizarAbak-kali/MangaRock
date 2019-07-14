//
//  MRCharacterCollectionViewCell.swift
//  MangaRock
//
//  Created by Tran Thi Cam Giang on 7/14/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import UIKit

class MRCharacterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius = avatarImageView.bounds.height/2
            avatarImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var characterName: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.sd_cancelImageLoadOperation(withKey: nil)
        avatarImageView.image = nil
        characterName.text = nil
    }
    
}
