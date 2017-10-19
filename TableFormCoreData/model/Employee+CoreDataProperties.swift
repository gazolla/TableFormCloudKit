//
//  Employee+CoreDataProperties.swift
//  TableFormCoreData
//
//  Created by Sebastiao Gazolla Costa Junior on 11/10/17.
//  Copyright © 2017 Sebastiao Gazolla Costa Junior. All rights reserved.
//
//

import Foundation
import CoreData


extension Employee {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Employee> {
        return NSFetchRequest<Employee>(entityName: "Employee")
    }

    @NSManaged public var email: String?
    @NSManaged public var name: String?
    @NSManaged public var birthday: NSDate?
    @NSManaged public var address: String?
    @NSManaged public var company: String?
    @NSManaged public var position: String?
    @NSManaged public var salary: NSDecimalNumber?
    @NSManaged public var gender: Gender?

}
