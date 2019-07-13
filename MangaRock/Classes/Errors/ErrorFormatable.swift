//
//  ErrorFormatable.swift
//  MangaRock
//
//  Created by giang tran on 7/13/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import Foundation

public protocol ErrorFormattable {
    var formattedErrorMessage: String { get }
}

extension Error {
    var formattedErrorMessage: String {
        if let error = self as? ErrorFormattable {
            return error.formattedErrorMessage
        }
                
        return "Unknow Error: \((self as NSError).localizedDescription)"
    }
}
