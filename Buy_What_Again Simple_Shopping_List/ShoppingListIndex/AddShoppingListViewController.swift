//
//  AddShoppingListViewController.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 5/5/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import UIKit

class AddShoppingListViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var listTypeSegment: UISegmentedControl!
    @IBOutlet weak var deadlinePicker: UIDatePicker!
    @IBOutlet weak var killSwitch: UISwitch!
    
    let TODAY = Date()
    var list: ShoppingList?

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        deadlinePicker.isHidden = true
        
        deadlinePicker.minimumDate = TODAY
        
        if let list = self.list {
            self.nameTextField.text = list.name
            if list.type == "Regular" {
                self.listTypeSegment.selectedSegmentIndex = 0
            } else if list.type == "Temproary" {
                self.listTypeSegment.selectedSegmentIndex = 1
            }
            if let dealine = list.deadline {
                self.deadlinePicker.date = list.deadline as! Date
                self.killSwitch.setOn(true, animated: true)
                self.deadlinePicker.isHidden = false
            } else {
                self.deadlinePicker.isHidden = true
            }
        }
    }
    
    @IBAction func onActivated(_ sender: Any) {
        if killSwitch.isOn {
            deadlinePicker.isHidden = false
        }
        else {
            deadlinePicker.isHidden = true
        }
    }
    
    
    
    @IBAction func onAddShoppingList(_ sender: Any) {
        if nameTextField.text != "" && listTypeSegment.selectedSegmentIndex == 0 {
            let name = nameTextField.text!
            let listType = listTypeSegment.titleForSegment(at: listTypeSegment.selectedSegmentIndex)
            var deadline: Date? = nil
            if killSwitch.isOn {
                deadline = deadlinePicker.date
            }
            if let list = self.list {
                let result = databaseController!.editList(name: name, type: listType!, deadLine: deadline, list: list)
                databaseController!.saveContext()
            } else {
                let _ = databaseController!.addList(name: name, type: listType!, deadLine: deadline)
                databaseController!.saveContext()
            }
            
            navigationController?.popViewController(animated: true)
            return
        } else if listTypeSegment.selectedSegmentIndex == 1 {
            let name = "Temporary List"
            let listType = listTypeSegment.titleForSegment(at: listTypeSegment.selectedSegmentIndex)
            var deadline: Date? = nil
            if killSwitch.isOn {
                deadline = deadlinePicker.date
            }
            if let list = self.list {
                let result = databaseController!.editList(name: name, type: listType!, deadLine: deadline, list: list)
                databaseController!.saveContext()
            } else {
                let _ = databaseController!.addList(name: name, type: listType!, deadLine: deadline)
                databaseController!.saveContext()
            }
            
            navigationController?.popViewController(animated: true)
            
        } else {
            displayMessage(title: "Error", message: "You need a name for your regular list")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Understood master!", style:
            UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}
