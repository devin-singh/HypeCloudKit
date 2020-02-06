//
//  UserModelController.swift
//  HypeCloudKit
//
//  Created by Devin Singh on 2/6/20.
//  Copyright © 2020 Devin Singh. All rights reserved.
//

import Foundation
import CloudKit

class UserController {
    
    //MARK: - Properties
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    var currentUser: User?
    
    static let shared = UserController()
    
    // MARK: - Private functions
    
    private func fetchAppleUserReference(completion: @escaping (CKRecord.Reference?) -> Void) {
        
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print(error, error.localizedDescription)
                return completion(nil)
            }
            
            guard let recordID = recordID else {  print("No record ID"); return completion(nil) }
            let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
            completion(reference)
        }
    }
    
    // MARK: - Class Methods
    
    func createUser(withUsername username: String, completion: @escaping (Result<User?, UserError>) -> Void) {
        
        fetchAppleUserReference { (reference) in
            guard let reference = reference else { return completion(.failure(.couldNotUnwrap)) }
            
            let newUser = User.init(username: username, appleUserRef: reference)
            
            let record = CKRecord(user: newUser)
            
            self.publicDB.save(record) { (record, error) in
                if let error = error {
                    print(error, error.localizedDescription)
                    return completion(.failure(.ckError(error)))
                }
                
                guard let record = record, let savedUser = User(ckRecord: record) else { return completion(.failure(.couldNotUnwrap)) }
                
                self.currentUser = savedUser
                print("created user: \(record.recordID.recordName) successfully")
                completion(.success(savedUser))
            }
        }
    }
    
    func fetchUser(completion: @escaping (Result<User?, UserError>) -> Void) {
        
        fetchAppleUserReference { (reference) in
            guard let reference = reference else { completion(.failure(.unexpectedRecordsFound)); return }
            
            let queryAllUserPredicate = NSPredicate(format: "%K == %@", argumentArray: [UserStrings.userRefKey, reference])
            
            let query = CKQuery(recordType: UserStrings.recordTypeKey, predicate: queryAllUserPredicate)
            
            self.publicDB.perform(query, inZoneWith: nil) { (records, error) in
                if let error = error {
                    return completion(.failure(.ckError(error)))
                }
                
                guard let record = records?.first, let foundUser = User(ckRecord: record) else { return completion(.failure(.couldNotUnwrap))}
                
                self.currentUser = foundUser
                
                completion(.success(foundUser))
            }
        }
        
        
    }
    
    func updateUser() {
        
    }
    
    func deleteUser() {
        
    }
}
