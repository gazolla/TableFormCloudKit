//
//  EmployeesController.swift
//  TableFormCoreData
//
//  Created by Sebastiao Gazolla Costa Junior on 11/10/17.
//  Copyright © 2017 Sebastiao Gazolla Costa Junior. All rights reserved.
//

import UIKit
import CoreData

class EmployeesController: UIViewController {
    
    var context:NSManagedObjectContext?
    
    lazy var employeeCtrl:EmployeeController = {
        let ec = EmployeeController()
        ec.context = self.context
        return ec
    }()
    
    lazy var tableView:UITableView = {
        let tv = UITableView(frame: self.view.bounds, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.dataSource = self
        tv.register(EmployeeCell.self, forCellReuseIdentifier:"cellid")
        return tv
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Employee>? = {
        guard let context = context else { return nil }
        let fetchRequest: NSFetchRequest<Employee> = Employee.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Employee.name), ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    
    fileprivate func loadData() {
        guard let fetchedRstCtrl = self.fetchedResultsController else { return }
        do {
            try fetchedRstCtrl.performFetch()
        } catch {
            print("Unable to Perform Fetch Request")
            print("\(error), \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        title = "Employees"
        navigationController?.navigationBar.prefersLargeTitles = true
        let btn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addEmployeeTapped))
        self.navigationItem.rightBarButtonItem = btn
        
        loadData()
    }
    
    @objc func addEmployeeTapped(){
        employeeCtrl.data = Employee.emptyDic()
        self.navigationController?.pushViewController(employeeCtrl, animated: true)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
    }
}

extension EmployeesController:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let fetchedRstCtrl = self.fetchedResultsController, let sections = fetchedRstCtrl.sections else { return 0 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let fetchedRstCtrl = self.fetchedResultsController, let section = fetchedRstCtrl.sections?[section] else { return 0 }
        return section.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath) as! EmployeeCell
        guard let fetchedRstCtrl = self.fetchedResultsController else { return cell }
        let employee = fetchedRstCtrl.object(at: indexPath)
        cell.employee = employee
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard let fetchedRstCtrl = self.fetchedResultsController, let context = context else { return }
        let note = fetchedRstCtrl.object(at: indexPath)
        context.delete(note)
        do{
            try context.save()
        } catch {
            print(error)
        }
    }
    
}

extension EmployeesController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let fetchedRstCtrl = self.fetchedResultsController else { return }
        let employee = fetchedRstCtrl.object(at: indexPath)
        employeeCtrl.title = "Edit Employee"
        employeeCtrl.data = employee.objToDic()
        self.navigationController?.pushViewController(employeeCtrl, animated: true)
    }
}

extension EmployeesController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? EmployeeCell {
                guard let fetchedRstCtrl = self.fetchedResultsController else { return }
                cell.employee = fetchedRstCtrl.object(at: indexPath)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        }
    }
}

class EmployeeCell: UITableViewCell {
    
    var employee:Employee?{
        didSet{
            guard let p = employee else { return }
            self.textLabel?.text = "\(p.name!)"
            self.detailTextLabel?.text = p.email!
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

