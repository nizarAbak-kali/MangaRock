//
//  MRMangaInfoViewController.swift
//  MangaRock
//
//  Created by Tran Thi Cam Giang on 7/14/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import UIKit

class MRMangaInfoViewController: UIViewController {
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var characterCollectionView: UICollectionView!
    
    var manga: MangaViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    private func setupUI() {
        characterCollectionView.dataSource = self
        characterCollectionView.delegate = self
//        characterCollectionView.register(MRCharacterCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: MRCharacterCollectionViewCell.self))
        coverImageView.sd_setImage(with: URL(string: manga.coverImage), completed: nil)
        thumbnailImageView.sd_setImage(with: URL(string: manga.thumbnailImage), completed: nil)
        titleLabel.text = manga.name
        authorNameLabel.text = manga.authorName
        descriptionLabel.text = manga.mangaDescription
        
    }

}

extension MRMangaInfoViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return manga.characters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MRCharacterCollectionViewCell.self), for: indexPath) as! MRCharacterCollectionViewCell
        let character = manga.characters[indexPath.row]
        configureCell(cell, with: character)
        return cell
    }
    
    private func configureCell(_ cell: MRCharacterCollectionViewCell, with character: CharacterViewModel) {
        cell.avatarImageView.sd_setImage(with: URL(string: character.avatarImage), completed: nil)
        cell.characterName.text = character.name
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 88, height: 116)
    }
    
}


