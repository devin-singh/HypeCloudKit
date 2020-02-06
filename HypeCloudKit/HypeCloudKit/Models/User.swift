//
//  User.swift
//  HypeCloudKit
//
//  Created by Devin Singh on 2/6/20.
//  Copyright © 2020 Devin Singh. All rights reserved.
//

import Foundation
import CloudKit

struct UserStrings {
    static let recordTypeKey = "User"
    fileprivate static let usernameKey = "username"
    fileprivate static let bioKey = "bio"
    static let userRefKey = "appleUserRef"
}

class User {
    
    var username: String
    var bio: String
    var recordID: CKRecord.ID
    var appleUserRef: CKRecord.Reference
    
    init(username: String, bio: String = "", recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), appleUserRef: CKRecord.Reference) {
        self.username = username
        self.bio = bio
        self.recordID = recordID
        self.appleUserRef = appleUserRef
    }
}

extension User {
    
    convenience init?(ckRecord: CKRecord) {
        
        guard let username = ckRecord[UserStrings.usernameKey] as? String, let bio = ckRecord[UserStrings.bioKey] as? String, let appleUserRef = ckRecord[UserStrings.userRefKey] as? CKRecord.Reference else { return nil }
        
        self.init(username: username, bio: bio, appleUserRef: appleUserRef)
    }
}

extension CKRecord {
    
    convenience init(user: User) {
        self.init(recordType: UserStrings.recordTypeKey, recordID: user.recordID)
        
        self.setValuesForKeys([
            UserStrings.usernameKey : user.username,
            UserStrings.bioKey : user.bio,
            UserStrings.userRefKey : user.appleUserRef
        ])
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}


