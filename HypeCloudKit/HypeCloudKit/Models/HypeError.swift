//
//  HypeError.swift
//  HypeCloudKit
//
//  Created by Devin Singh on 2/4/20.
//  Copyright © 2020 Devin Singh. All rights reserved.
//

import Foundation

enum HypeError: LocalizedError {
    
    case ckError(Error)
    case couldNotUnwrap
    
    var errorDescription: String? {
        switch self {
        case .ckError(let error):
            return error.localizedDescription
        case .couldNotUnwrap:
            return "Unable to get hype and uw it."
        }
    }
}
