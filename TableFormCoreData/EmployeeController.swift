//
//  MyFormView.swift
//  TableForm
//
//  Created by Gazolla on 05/10/17.
//  Copyright © 2017 Gazolla. All rights reserved.
//

import UIKit
import CoreData

class EmployeeController: FormViewController {
    var gender:Gender? {
        didSet{
            guard let gndr = gender else { return }
            print("fndr: \(gndr)")
            self.data!["gender"] = gndr as AnyObject
            self.setFormData()
        }
    }
    
    var context:NSManagedObjectContext?
    
    func createFieldsAndSections()->[[Field]]{
        let name = Field(name:"name", title:"Name:", cellType: NameCell.self)
        let birth = Field(name:"birthday", title:"Birthday:", cellType: DateCell.self)
        let address = Field(name:"address", title:"Address:", cellType: TextCell.self)
        let sectionPersonal = [name, address, birth]
        let company = Field(name:"company", title:"Company:", cellType: TextCell.self)
        let position = Field(name:"position", title:"Position:", cellType: TextCell.self)
        let email = Field(name:"email", title:"Email:", cellType: TextCell.self)
        let salary = Field(name:"salary", title:"Salary:", cellType: NumberCell.self)
        let sectionProfessional = [company, position, email, salary]
        let gender = Field(name: "gender", title:"Gender:", cellType: LinkCell.self)
        let sectionGender = [gender]
        return [sectionPersonal, sectionProfessional, sectionGender]
    }
    
    lazy var saveButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
    }()
    
    lazy var genderList = { ()-> TableViewController<Gender> in
        let genders:[Gender] = {
            var entities = [Gender]()
            guard let context = context else { return entities}
            let request:NSFetchRequest<Gender> = Gender.fetchRequest()
            do{
                entities = try context.fetch(request as! NSFetchRequest<NSFetchRequestResult>) as! [Gender]
            } catch {
                print(error)
            }
            return entities
        }()
        
        let genderList = TableViewController(items:genders, cellType: UITableViewCell.self)
        
        genderList.configureCell = { (cell, item, indexPath) in
            let item:Gender = item as Gender
            cell.textLabel?.text = "\(item.name!)"
        }
        
        genderList.selectedRow = { (controller, indexPath) in
            if let cell  = controller.tableView.cellForRow(at: indexPath as IndexPath){
                cell.accessoryType = .checkmark
                controller.selected = indexPath
            }
            let item:Gender = controller.items[indexPath.item]
            print("gende: \(item)")
            self.gender = item
            controller.navigationController?.popViewController(animated: true)
        }
        
        genderList.deselectedRow = { (controller, indexPath) in
            if controller.selected != nil {
                if let cell  = controller.tableView.cellForRow(at: controller.selected!){
                    cell.accessoryType = .none
                }
            }
        }
        
        genderList.title = "Gender"
        
        return genderList
    }()
    
    override init(){
        super.init()
        let its = createFieldsAndSections()
        self.items = its
        self.sections = buildCells(items: its)
        self.selectedRow = { [weak self] (form:FormViewController,indexPath:IndexPath) in
            let cell = form.tableView.cellForRow(at: indexPath)
            cell?.isSelected = false
            if cell is LinkCell {
                if (cell as! FormCell).name == "gender" {
                    self?.view.endEditing(true)
                    self?.navigationController?.pushViewController(self!.genderList, animated: true)
                }
            }
        }
    }
    
    override init(config:ConfigureForm){
        super.init(config:config)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Employee"
        navigationItem.rightBarButtonItem = saveButton
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func saveTapped(){
        guard let context = context else { return }
        let dic = self.getFormData()
        
        do{
            _ = try Employee.findOrCreate(dic:dic, in: context)
            try context.save()
        } catch {
            print(error)
        }
        
        navigationController?.popViewController(animated: true)
    }
}
