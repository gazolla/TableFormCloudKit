//
//  EmployeesController.swift
//  TableFormCoreData
//
//  Created by Sebastiao Gazolla Costa Junior on 11/10/17.
//  Copyright © 2017 Sebastiao Gazolla Costa Junior. All rights reserved.
//

import UIKit
import CloudKit

class EmployeesController: UITableViewController {
    
    let employeeCtrl = EmployeeController()
    
    var items:[CKRecord]? {
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EmployeeCell.self, forCellReuseIdentifier:"cellid")
        
        title = "Employees"
        navigationController?.navigationBar.prefersLargeTitles = true
        let btn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addEmployeeTapped))
        self.navigationItem.rightBarButtonItem = btn
        
        NotificationCenter.default.addObserver(self, selector: #selector(addItem), name: NSNotification.Name(rawValue: "AddEmployee"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteItem), name: NSNotification.Name(rawValue: "DeleteEmployee"), object: nil)

    }
    
    @objc func addEmployeeTapped(){
        employeeCtrl.data = emptyDic()
        employeeCtrl.hiddenData = ["record": nil]
        self.navigationController?.pushViewController(employeeCtrl, animated: true)
    }
    
    func emptyDic()->[String:AnyObject?]{
        return ["email" : "" as AnyObject
            , "name" : "" as AnyObject
            , "birthday" : Date() as AnyObject
            , "address" : "" as AnyObject
            , "company" : "" as AnyObject
            , "position" : "" as AnyObject
            , "salary" : 0.0 as AnyObject
            , "gender" :  nil ]
    }

    fileprivate func add(_ record: CKRecord) {
        if let items = items {
            var result = items.filter({($0 as CKRecord).recordID != record.recordID })
            result.append(record)
            result.sort(by: { (rec1, rec2) -> Bool in
                return ((rec1 as CKRecord)["name"] as! String) < ((rec2 as CKRecord)["name"] as! String)
            })
            self.items = result
        }
    }
    
    @objc func addItem(notification:Notification){
        if let record = notification.object as? CKRecord{
            
            add(record)
            
        } else {
            print("record not received")
        }
    }
    
    fileprivate func delete(_ recordId: CKRecordID) {
        if let items = items {
            var result = items.filter({($0 as CKRecord).recordID != recordId })
            result.sort(by: { (rec1, rec2) -> Bool in
                return ((rec1 as CKRecord)["name"] as! String) < ((rec2 as CKRecord)["name"] as! String)
            })
            self.items = result
        }
    }
    
    @objc func deleteItem(notification:Notification){
        if let recordId = notification.object as? CKRecordID{
            delete(recordId)
        } else {
            print("record not received")
        }
    }
    
}

extension EmployeesController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath) as! EmployeeCell
        let item = items?[indexPath.item]
        let employee = item
        cell.employee = employee
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard let items = self.items else { return }
        let employee = items[indexPath.item]
        deleteEmployee(employee)
        delete(employee.recordID)
    }
    
}

extension EmployeesController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items?[indexPath.item]
        if let it = item {
            employeeCtrl.data = toDic(record: it)
            employeeCtrl.hiddenData = ["record": it]
            self.navigationController?.pushViewController(employeeCtrl, animated: true)
        }
    }
}


class EmployeeCell: UITableViewCell {
    
    var employee:CKRecord?{
        didSet{
            guard let p = employee else { return }
            self.textLabel?.text = p["name"] as? String
            self.detailTextLabel?.text = p["email"] as? String
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required  public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override  open func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

