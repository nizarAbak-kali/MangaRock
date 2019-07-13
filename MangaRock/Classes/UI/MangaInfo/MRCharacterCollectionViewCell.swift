//
//  MRCharacterCollectionViewCell.swift
//  MangaRock
//
//  Created by Tran Thi Cam Giang on 7/14/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import UIKit

class MRCharacterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var characterName: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.sd_cancelImageLoadOperation(withKey: nil)
        avatarImageView.image = nil
        characterName.text = nil
    }
    
}
