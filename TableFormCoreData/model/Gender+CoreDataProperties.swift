//
//  Gender+CoreDataProperties.swift
//  TableFormCoreData
//
//  Created by Sebastiao Gazolla Costa Junior on 11/10/17.
//  Copyright © 2017 Sebastiao Gazolla Costa Junior. All rights reserved.
//
//

import Foundation
import CoreData


extension Gender {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Gender> {
        return NSFetchRequest<Gender>(entityName: "Gender")
    }

    @NSManaged public var name: String?
    @NSManaged public var employees: NSSet?

}

// MARK: Generated accessors for employees
extension Gender {

    @objc(addEmployeesObject:)
    @NSManaged public func addToEmployees(_ value: Employee)

    @objc(removeEmployeesObject:)
    @NSManaged public func removeFromEmployees(_ value: Employee)

    @objc(addEmployees:)
    @NSManaged public func addToEmployees(_ values: NSSet)

    @objc(removeEmployees:)
    @NSManaged public func removeFromEmployees(_ values: NSSet)

}
