//
//  NewShoppingListTableViewController.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Long Lee on 12/2/2020.
//  Copyright © 2020 Chak Lee. All rights reserved.
//

import UIKit

class NewShoppingListTableViewController: UITableViewController, UITextFieldDelegate {
    
    weak var switchCell: UITableViewCell?
    weak var selectCell: UITableViewCell?
    weak var textCell: UITableViewCell?
    weak var datePickerCell: UITableViewCell?
    weak var databaseController: DatabaseProtocol?
    
    var regularList = true
    var list: ShoppingList?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        if let list = self.list {
            self.title = list.name
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismisskeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismisskeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return "List Detail"
            case 1:
                return "Deadline"
            default:
                return "Error"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let currentCell = indexPath.row + indexPath.section * 2
        
        switch currentCell {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "selectionCell", for: indexPath) as! SelectionTableViewCell
                cell.accessoryType = .disclosureIndicator
                cell.selectionRef.text = "List Type"
                
                if let list = self.list {
                    if !(list.type == "Regular") && (self.selectCell == nil) {
                        self.regularList = false
                    }
                }
                if self.regularList {
                    cell.decisionRef.text = "Regular"
                }
                else {
                    cell.decisionRef.text = "Temproary"
                }
                self.selectCell = cell

                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! TextTableViewCell
                cell.selectionStyle = .none
                if self.regularList {
                    cell.textRef.isEnabled = true
                    cell.textRef.placeholder = "List Name"
                    
                    if let list = self.list {
                        if (self.textCell == nil) || (cell.textRef.text == ""){
                            cell.textRef.text = list.name
                        }
                    }
                }
                else {
                    cell.textRef.isEnabled = false
                    cell.textRef.placeholder = "Temproary List"
                    cell.textRef.text = ""
                }
                self.textCell = cell
                cell.textRef.delegate = self
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! SwitchTableViewCell
                cell.selectionStyle = .none
                cell.newShoppingListRef(self)
                
                if let list = self.list {
                    if (list.deadline != nil) && (self.switchCell == nil) {
                        cell.switchRef.setOn(true, animated: true)
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat =  "d MMM, yyy HH:mm"
                        let date = dateFormatter.string(from: list.deadline as! Date)
                        cell.dateLabelRef.text = date
                        cell.dateLabelRef.isHidden = false
                    }
                }
                self.switchCell = cell
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "dateTimeCell", for: indexPath) as! DateTimeTableViewCell
                cell.selectionStyle = .none
                cell.newShoppingListRef(self)
                
                
                if let list = self.list {
                    if (list.deadline != nil) && (self.datePickerCell == nil) {
                        cell.dateTimeRef.date = list.deadline as! Date
                    }
                }
                self.datePickerCell = cell
                return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 1 && indexPath.row == 1) {
            let cell = self.switchCell as! SwitchTableViewCell
            if (cell.switchRef.isOn) {
                return 200
            }
            return 0
        }
        
        else {
            return tableView.rowHeight
        }
    }
    
    @IBAction func onAddShoppingList(_ sender: Any) {
        let selectCellRef = self.selectCell as! SelectionTableViewCell
        let textCellRef = self.textCell as! TextTableViewCell
        let switchCellRef = self.switchCell as! SwitchTableViewCell
        let datePickerCellRef = self.datePickerCell as! DateTimeTableViewCell
        
        if (textCellRef.textRef.text != "" && textCellRef.textRef.isEnabled) {
            let name = textCellRef.textRef.text!
            let chars = Array(name)
            if (name.count > 25) {
                self.displayMessage(title: "Long name huh?", message: "Please name your list with no longer than 25 characters.")
                return
            }
            else {
                for char in chars {
                    switch char {
                    case "<", ">", "\"", "/", "|", "?", "*", "$":
                        self.displayMessage(title: "Invalid list name", message: "Make sure the name doesn't contain these character: <>|/|?*$")
                        return
                    default:
                        continue
                    }
                }
            }
            let listType = selectCellRef.decisionRef.text!
            var deadline: Date? = nil
            if switchCellRef.switchRef.isOn {
                deadline = datePickerCellRef.dateTimeRef.date
            }
            if let list = self.list {
                let result = databaseController!.editList(name: name, type: listType, deadLine: deadline, list: list)
                databaseController!.saveContext()
            } else {
                let _ = databaseController!.addList(name: name, type: listType, deadLine: deadline)
            }
            
            navigationController?.popViewController(animated: true)
            return
        } else if !(textCellRef.textRef.isEnabled) {
            let name = "Temproary List"
            let listType = selectCellRef.decisionRef.text!
            var deadline: Date? = nil
            if switchCellRef.switchRef.isOn {
                deadline = datePickerCellRef.dateTimeRef.date
            }
            if let list = self.list {
                let result = databaseController!.editList(name: name, type: listType, deadLine: deadline, list: list)
                databaseController!.saveContext()
            } else {
                let test = databaseController!.addList(name: name, type: listType, deadLine: deadline)
                databaseController!.saveContext()
                print(test)
            }
            
            navigationController?.popViewController(animated: true)
        } else {
            displayMessage(title: "Error", message: "You need a name for your regular list")
        }

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "listTypeSegue") {
            let destination = segue.destination as! ListTypeTableViewController
            let cell = self.selectCell as! SelectionTableViewCell
            destination.listType = self.regularList
            destination.tableViewController = self
        }
    }
    
    func reloadDate() {
        let cell = self.switchCell as! SwitchTableViewCell
        cell.loadDate()
    }
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style:
            UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}
