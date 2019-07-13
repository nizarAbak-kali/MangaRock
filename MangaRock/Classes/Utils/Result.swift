//
//  Result.swift
//  MangaRock
//
//  Created by giang tran on 7/13/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(data: T)
    case failure(error: Error)
}
