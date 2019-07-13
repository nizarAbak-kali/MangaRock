//
//  CoreDataError.swift
//  MangaRock
//
//  Created by giang tran on 7/13/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import Foundation

enum CoreDataError: Error, ErrorFormattable {
    case wrongObjectType
    case wrongObjectModelAndContext
    case wrongObjectModelPath
    case invalidObjectModelFile
    case somethingWentWrong
    
    var formattedErrorMessage: String {
        switch self {
        case .wrongObjectType:
            return "Wrong Object Type"
        case .wrongObjectModelAndContext:
            return "Wrong Object Model Type And Context"
        case .wrongObjectModelPath:
            return "Wrong object model path"
        case .invalidObjectModelFile:
            return "Invalid object model file"
        case .somethingWentWrong:
            return "Coredata, something went wrong"
        }
    }
}
