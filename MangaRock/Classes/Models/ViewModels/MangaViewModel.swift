//
//  MangaViewModel.swift
//  MangaRock
//
//  Created by giang tran on 7/13/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import Foundation

struct MangaViewModel: ViewModelProtocol {
    let objectID: ObjectID
    let authorName: String
    let coverImage: String
    let mangaDescription: String
    let name: String
    let thumbnailImage: String
    
    let characters: [CharacterViewModel]
}
