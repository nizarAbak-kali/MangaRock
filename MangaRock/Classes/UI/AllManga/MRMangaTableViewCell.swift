//
//  MRMangaTableViewCell.swift
//  MangaRock
//
//  Created by Vien Tran on 2/16/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import UIKit

class MRMangaTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        nameLabel.text = nil
        authorLabel.text = nil
    }
}
