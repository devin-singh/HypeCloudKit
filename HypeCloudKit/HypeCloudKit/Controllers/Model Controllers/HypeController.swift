//
//  HypeController.swift
//  HypeCloudKit
//
//  Created by Devin Singh on 2/4/20.
//  Copyright © 2020 Devin Singh. All rights reserved.
//

import Foundation
import CloudKit

class HypeController {
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    static let shared = HypeController()
    
    var hypes: [Hype] = []
    
    // MARK: - CRUD
    
    func saveHype(with bodyText: String, completion: @escaping (Result<Hype?, HypeError>) -> Void) {
        
        guard let currentUser = UserController.shared.currentUser else { return completion(.failure(.noUserLoggedIn)) }
        
        let reference = CKRecord.Reference(recordID: currentUser.recordID, action: .none)
        
        let newHype = Hype(body: bodyText, userReference: reference)
        
        let hypeRecord = CKRecord(hype: newHype)
        
        publicDB.save(hypeRecord) { (record, error) in
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = record,
            let savedHype = Hype(ckRecord: record)
                else { return completion(.failure(.couldNotUnwrap))}
            print("Saved Hype successfully")
            
            completion(.success(savedHype))
        }
    }
    
    func fetchAllHypes(completion: @escaping (Result<[Hype], HypeError>) -> Void) {
        
        let queryAllPredicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: HypeStrings.recordTypeKey, predicate: queryAllPredicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let records = records else { return completion(.failure(.couldNotUnwrap))}
            
            // each record is being assigned as a hype and being appeneded into an array
            let hypes = records.compactMap({ Hype(ckRecord: $0) })
            
            completion(.success(hypes))
        }
    }
    
    func update(_ hype: Hype, completion: @escaping (Result<Hype, HypeError>) -> Void) {
        
        guard hype.userReference?.recordID == UserController.shared.currentUser?.recordID else { return completion(.failure(.unexpectedRecordsFound)) }
        
        let record = CKRecord(hype: hype)
        
        // Create an Operation
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        // Set the properties on the operation
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { records, _, error in
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = records?.first, let updatedHype = Hype(ckRecord: record) else { return completion(.failure(.couldNotUnwrap))}
            
            completion(.success(updatedHype))
        }
        publicDB.add(operation)
    }
    
    func delete(_ hype: Hype, completion: @escaping (Result<Bool, HypeError>) -> Void) {
        
        guard hype.userReference?.recordID == UserController.shared.currentUser?.recordID else { return completion(.failure(.unexpectedRecordsFound)) }
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [hype.recordID])
        
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        
        operation.modifyRecordsCompletionBlock = { records, _, error in
            if let error = error {
                completion(.failure(.ckError(error)))
            }
            
            if records?.count == 0 {
                completion(.success(true))
            }else{
                return completion(.failure(.unexpectedRecordsFound))
            }
            
        }
        publicDB.add(operation)
    }
    
    func subscribeForRemoteNotifications(completion: @escaping (_ error: Error?) -> Void) {
        
        let predicate = NSPredicate(value: true)
        
        let subscription = CKQuerySubscription(recordType: HypeStrings.recordTypeKey, predicate: predicate, options: .firesOnRecordCreation)
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "CHOO CHOO"
        notificationInfo.alertBody = "Can't Stop the Hype Train!"
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
        
        subscription.notificationInfo = notificationInfo
        
        publicDB.save(subscription) { (_, error) in
            
            if let error = error {
                completion(error)
            }
            
            completion(nil)
        }
    }
}
