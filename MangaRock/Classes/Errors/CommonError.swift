//
//  CommonError.swift
//  MangaRock
//
//  Created by giang tran on 7/13/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import Foundation

enum CommonError: Error, ErrorFormattable {
    case somethingWentWrong
    
    var formattedErrorMessage: String {
        switch self {
        case .somethingWentWrong:
            return "Common, something went wrong"
        }
    }
}
