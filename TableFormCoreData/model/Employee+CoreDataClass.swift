//
//  Employee+CoreDataClass.swift
//  TableFormCoreData
//
//  Created by Sebastiao Gazolla Costa Junior on 11/10/17.
//  Copyright © 2017 Sebastiao Gazolla Costa Junior. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Employee)
public class Employee: NSManagedObject {
    class var dateFmtr:DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }
    
    class var NumFmtr:NumberFormatter {
        let f = NumberFormatter()
        f.generatesDecimalNumbers = true
        return f
    }
    
    class func findOrCreate(dic:[String:AnyObject?], in context:NSManagedObjectContext) throws -> Employee?{
        
        let request:NSFetchRequest<Employee> = Employee.fetchRequest()
        
        guard let email = dic["email"] as? String  else {
            return nil
        }
        
        request.predicate = NSPredicate(format: "email = %@", email)
        do{
            let matches = try context.fetch(request)
            if matches.count > 0 {
                var employee = matches[0]
                dicToObj(obj: &employee, dic: dic)
                return employee
            }
        } catch {
            throw error
        }
       
        var employee:Employee = Employee(context:context)
        dicToObj(obj: &employee, dic: dic)
        return employee
        
    }

}

extension Employee {
    class func emptyDic()->[String:AnyObject?]{
        return ["email" : "" as AnyObject
            , "name" : "" as AnyObject
            , "birthday" : Date() as AnyObject
            , "address" : "" as AnyObject
            , "company" : "" as AnyObject
            , "position" : "" as AnyObject
            , "salary" : 0.0 as AnyObject
            , "gender" : "" as AnyObject]
    }
    
    func objToDic()->[String:AnyObject?]{
        return ["email" : self.email as AnyObject
            , "name" : self.name as AnyObject
            , "birthday" : self.birthday as AnyObject
            , "address" : self.address as AnyObject
            , "company" : self.company as AnyObject
            , "position" : self.position as AnyObject
            , "salary" : self.salary as AnyObject
            , "gender" : self.gender as AnyObject]
    }
    
    class func dicToObj( obj:inout Employee, dic:[String:AnyObject?]) {

        obj.email = dic["email"] as? String
        obj.name = dic["name"] as? String
        obj.birthday = dateFmtr.date(from: (dic["birthday"] as? String)!)! as NSDate
        obj.address = dic["address"] as? String
        obj.company = dic["company"] as? String
        obj.position = dic["position"] as? String
        obj.gender = dic["gender"] as? Gender
        
        if let numberString = dic["salary"] as? String {
            let decimalSeparator = Locale.current.decimalSeparator ?? "."
            let characters = "-0123456789" + decimalSeparator
            let decimalFilter  = CharacterSet(charactersIn:characters)
            let cleanNumberStr = numberString.components(separatedBy:decimalFilter.inverted).joined(separator:"")
            obj.salary = NSDecimalNumber(string: cleanNumberStr, locale:Locale.current)
        }
  
    }
}
