//
//  CloudKitOperations.swift
//  CloudKit101
//
//  Created by Gazolla on 16/07/2018.
//  Copyright © 2018 Gazolla. All rights reserved.
//

import Foundation
import CloudKit

let subscriptionID = "EmployeeSubID"
var cloudKitObserver:NSObjectProtocol?

func iCloudSubscribe(){
    let database = CKContainer.default().privateCloudDatabase
    let predicate = NSPredicate(value: true)
    let subscription = CKQuerySubscription(recordType: "Employee", predicate: predicate, subscriptionID: subscriptionID, options: [.firesOnRecordCreation, .firesOnRecordDeletion, .firesOnRecordUpdate])
    
    let info = CKNotificationInfo()
    info.shouldSendContentAvailable = true
    subscription.notificationInfo = info
    
    database.save(subscription) { (savedSubscription, error) in
        if let error = error {
            print(error.localizedDescription)
        }
    }
    
    
}


func searchGender(str:String, completion: @escaping (_ records:[CKRecord]?)->()){
    let database:CKDatabase = CKContainer.default().privateCloudDatabase
    let predicate = NSPredicate(format: "name = %@", "Male")
    let query = CKQuery(recordType: "Gender", predicate: predicate)
    database.perform(query, inZoneWith: nil) { (records, error) in
        if let error = error {
            print(error.localizedDescription)
        }
        completion(records)
    }
}



func toDic(record:CKRecord) -> [String:AnyObject?]{
    var result = [String:AnyObject?]()
    result["name"] = record["name"] as? NSString
    result["email"] = record["email"] as? NSString
    result["birthday"] = record["birthday"] as? NSDate
    result["address"] = record["address"] as? NSString
    result["company"] = record["company"] as? NSString
    result["position"] = record["position"] as? NSString
    result["gender"] = record["gender"] as? CKReference
    return result
}

func add(_ employee:[String:AnyObject?]){
    let f = DateFormatter()
    f.dateStyle = .medium
    
    let database = CKContainer.default().privateCloudDatabase
    if let record = employee["record"] as? CKRecord {
        record["name"] = employee["name"] as? CKRecordValue
        record["email"] = employee["email"] as? CKRecordValue
        record["birthday"] = f.date(from: (employee["birthday"] as! String))! as CKRecordValue
        record["address"] = employee["address"] as? CKRecordValue
        record["company"] = employee["company"] as? CKRecordValue
        record["position"] = employee["position"] as? CKRecordValue
        record["gender"] = employee["gender"] as? CKRecordValue
        database.save(record) { (record, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AddEmployee"), object: record)
        }
    } else {
        addEmployee(employee)
    }
    
    
}

func addEmployee(_ employee:[String:AnyObject?]){
    let f = DateFormatter()
    f.dateStyle = .medium

    let database = CKContainer.default().privateCloudDatabase
    let record = CKRecord(recordType: "Employee")
    record["name"] = employee["name"] as? CKRecordValue
    record["email"] = employee["email"] as? CKRecordValue
    record["birthday"] = f.date(from: (employee["birthday"] as! String))! as CKRecordValue
    record["address"] = employee["address"] as? CKRecordValue
    record["company"] = employee["company"] as? CKRecordValue
    record["position"] = employee["position"] as? CKRecordValue
    record["gender"] = employee["gender"] as? CKRecordValue
    database.save(record) { (record, error) in
        if let error = error {
            print(error.localizedDescription)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AddEmployee"), object: record)
    }
}

func addGender(){
    let f = DateFormatter()
    f.dateStyle = .medium
    
    let database:CKDatabase = CKContainer.default().privateCloudDatabase
    
        let record = CKRecord(recordType: "Gender")
        record["name"] = "Male" as NSString
        database.save(record) { (record, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
}


func getAllEmployees(completion: @escaping (_ records:[CKRecord]?)->Void){
    let database = CKContainer.default().privateCloudDatabase
    let predicate = NSPredicate(value: true)
    let query = CKQuery(recordType: "Employee", predicate: predicate)
    query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    database.perform(query, inZoneWith: nil) { (records, error) in
        if let error = error {
            print(error.localizedDescription)
        }
        completion(records)
    }
}

func searchEmployeeByName(_ str:String, completion: @escaping(_ records:[CKRecord]?)->Void){
    let database = CKContainer.default().privateCloudDatabase
    let predicate = NSPredicate(format: "name = %@", str)
    let query = CKQuery(recordType: "Employee", predicate: predicate)
    database.perform(query, inZoneWith: nil) { (records, error) in
        if let error = error {
            print(error.localizedDescription)
        }
        completion(records)
    }
}

func searchEmployeeByPosition(_ str:String, completion: @escaping(_ records:[CKRecord]?)->Void){
    let database = CKContainer.default().privateCloudDatabase
    let predicate = NSPredicate(format: "position = %@", str)
    let query = CKQuery(recordType: "Employee", predicate: predicate)
    database.perform(query, inZoneWith: nil) { (records, error) in
        if let error = error {
            print(error.localizedDescription)
        }
        completion(records)
    }
}

func deleteEmployee(_ record:CKRecord){
    let database = CKContainer.default().privateCloudDatabase
    database.delete(withRecordID: record.recordID) { (recordID, error) in
        if let error = error {
            print(error.localizedDescription)
        }
    }
}






























