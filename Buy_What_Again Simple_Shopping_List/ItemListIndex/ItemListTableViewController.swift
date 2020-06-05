//
//  ItemListTableViewController.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 3/5/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

//Copyright 2019 Google
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

import UIKit

class ItemListTableViewController: UITableViewController, DatabaseListener {
    
    var allItem: [Item] = []
    var key: [BackupKey] = []
    weak var databaseController: DatabaseProtocol?
    var firebaseController: FirebaseController?

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        firebaseController = appDelegate.firebaseController
        

        
    }
    

    
    //Call the display menu method when the ? icon was pressed
    @IBAction func onBackupList(_ sender: Any) {
        self.showSelection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    var listenerType = ListenerType.item
    
    func onShoppingListChange(change: DatabaseChange, shoppList: [ShoppingList]) {
        //not used
    }
    //Fetch the Item list from CoreData
    func onItemListChange(change: DatabaseChange, itemList: [Item]) {
        allItem = itemList
    }
    
    func onGroceriesListChange(change: DatabaseChange, groceriesList: [Grocery]) {
        //not used
    }
    
    func onShopListChange(change: DatabaseChange, shopList: [Shop]) {
        //not used
    }
    //Fetch the backup key of the item list if exist
    func onKeyChange(change: DatabaseChange, key: [BackupKey]) {
        self.key = key
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItem.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        
        let list = allItem[indexPath.row]

        itemCell.textLabel?.text = list.name
        return itemCell
    }
    
    //Create a delete action for each cell to delete an Item
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "delete", handler: {action, index in
            let deleteItem = self.allItem[indexPath.row]
            self.allItem.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            let _ = self.databaseController?.removeItem(item: deleteItem)
        })
        
        delete.backgroundColor = .red
        
        return [delete]
    }
    
    @IBAction func onAddItem(_ sender: Any) {
        let alertController = UIAlertController(title: "New Item", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Add", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction) in
            if let textField = alertController.textFields {
                let name = textField[0].text!
                if name != "" {
                    let chars = Array(name)
                    if (name.count > 25) {
                        self.displayMessage(title: "Nice Item!", message: "Sorry but please name the item with no longer than 25 characters.")
                        return
                    }
                    else {
                        for char in chars {
                            switch char {
                            case "<", ">", "\"", "/", "|", "?", "*", "$":
                                self.displayMessage(title: "Invalid Item name", message: "Make sure the name doesn't contain these character: <>|/|?*$")
                                return
                            default:
                                continue
                            }
                        }
                    }

                    let _ = self.databaseController?.addItem(name: name)
                    self.databaseController!.saveContext()
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.displayMessage(title: "Error", message: "Invalid item name")
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }))
        alertController.addTextField { textField in
            textField.placeholder = "Item Name"
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style:
            UIAlertAction.Style.destructive, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func dismisskeyboard() {
        view.endEditing(true)
    }
    
    //Show user a message with the alert message box
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style:
            UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
// MARK: - Unused content
    //Show user the backup key of the Item list if exist
    func backupMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style:
            UIAlertAction.Style.default, handler: nil))
        //Give user the option to copy the code into the clip board
        alertController.addAction(UIAlertAction(title: "Copy code", style:
        UIAlertAction.Style.default) { _ in
            if let code = self.key[0].code {
                UIPasteboard.general.string = code
            }
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    //Ask user for a backup key for restoring the item list, only if there's a backup list for restoring
    func restoreMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField(configurationHandler: nil)
        
        alertController.addAction(UIAlertAction(title: "Restore", style:
        UIAlertAction.Style.default) { _ in
            if let text = alertController.textFields![0].text {
                self.restoreList(key: text)
            }
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style:
        UIAlertAction.Style.cancel) { _ in
            if let code = self.key[0].code {
                UIPasteboard.general.string = code
            }
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    //Called when user choose to backup the current list, do nothing if a backup list already exist
    func backupList() {
        if self.key.count > 0 {
            backupMessage(title: "You already have a backup list", message: "backup key: \(self.key[0].code!)")
            return
        }
        let keyCode = KeyCode()
        keyCode.generateKeyCode()
        let keyString = keyCode.toString()
        let backupKey = databaseController!.addKey(key: keyString)
        self.key.append(backupKey)
        databaseController!.saveContext()
        let _ = firebaseController!.backupList(key: keyString, items: allItem)
        backupMessage(title: "List saved", message: "Use the following code to retrieve the list: \(keyString)")
    }
    
    //Called when user entered a backup key for restoring the item list, do nothing if the key doesn't match any list on Firebase
    func restoreList(key: String) {
        
        firebaseController!.fetchListByKey(key: key)
        let newList = firebaseController!.getList()
        if newList.count == 0 {
            displayMessage(title: "Error", message: "Cannot fetch new list")
            return
        } else {
            displayMessage(title: "Warning", message: "Your list has been restored")
            for item in self.allItem {
                let _ = databaseController!.removeItem(item: item)
            }
            self.allItem = []
            for item in newList {
                self.allItem.append(databaseController!.addItem(name: item))
            }
            tableView.reloadData()
        }
        
    }
    
    //Remove the existing backup list on Firebase, do nothing if the user doesn't have one
    func removeBackupList() {
        if key.count > 0, let code = key[0].code {
            let _ = firebaseController!.removeBackupList(key: code)
            databaseController!.removeKey(key: key[0])
            self.key.remove(at: 0)
            databaseController!.saveContext()
            displayMessage(title: "Success", message: "Your no longer have a backup list")
        } else {
            displayMessage(title: "Error", message: "You don't have a backup list")
        }
    }
    
    //Show user possible interaction with the Item list
    func showSelection() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Backup list", style: .default) { _ in
            self.backupList()
        })
        
        alertController.addAction(UIAlertAction(title: "Restore list", style: .default) { _ in
            self.restoreMessage(title: "Restore List", message: "Enter your list backupKey")
        })
        
        alertController.addAction(UIAlertAction(title: "Remove backupCode", style: .destructive) { _ in
            self.removeBackupList()
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true)
    }

}
