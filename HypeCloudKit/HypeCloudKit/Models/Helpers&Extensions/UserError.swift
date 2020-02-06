//
//  UserError.swift
//  HypeCloudKit
//
//  Created by Devin Singh on 2/6/20.
//  Copyright © 2020 Devin Singh. All rights reserved.
//

import Foundation


enum UserError: LocalizedError {
    
    case ckError(Error)
    case couldNotUnwrap
    case unexpectedRecordsFound
    
    var errorDescription: String? {
        switch self {
        case .ckError(let error):
            return error.localizedDescription
        case .couldNotUnwrap:
            return "Unable to get hype and uw it."
        case .unexpectedRecordsFound:
            return "Unexpected records were returned when trying to delete"
        }
        
    }
}
