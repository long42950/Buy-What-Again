//
//  ShoppingListTableViewController.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 5/5/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import UIKit

class ShoppingListTableViewController: UITableViewController, DatabaseListener {

    var allList: [ShoppingList] = []
    var chosenList: String?
    var editRow: Int = -1
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        self.tableView.rowHeight = 70
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        self.editRow = -1
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    var listenerType = ListenerType.list
    //Fetch all ShoppingList from CoreData
    func onShoppingListChange(change: DatabaseChange, shoppList: [ShoppingList]) {
        allList = shoppList
    }
    
    func onItemListChange(change: DatabaseChange, itemList: [Item]) {
        //not used
    }
    
    func onGroceriesListChange(change: DatabaseChange, groceriesList: [Grocery]) {
        //not used
    }
    
    func onShopListChange(change: DatabaseChange, shopList: [Shop]) {
        //not used
    }
    func onKeyChange(change: DatabaseChange, key: [BackupKey]) {
        //not used
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allList.count
    }
    
    //Configure what information to be shown from the ShoppingList
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let shoppingListCell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ShoppingListTableViewCell
        let shoppingList = allList[indexPath.row]
        shoppingListCell.nameLabel.text = shoppingList.name!
        if shoppingList.deadline != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateFormatter.locale = Locale(identifier: "en_AU")
            
            shoppingListCell.dateLabel.text = dateFormatter.string(from: shoppingList.deadline! as Date)
        }
        else {
            shoppingListCell.dateLabel.text = "not available"
        }

        return shoppingListCell
    }
    
    //Create a delete action for each cell to delete a ShoppingList, also an edit action to edit the list's details
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "delete", handler: {action, index in
            let deleteList = self.allList[indexPath.row]
            self.allList.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            let _ = self.databaseController?.removeList(list: deleteList)
            self.databaseController?.saveContext()
        })
        
        delete.backgroundColor = .red
        
        let edit = UITableViewRowAction(style: .normal, title: "edit", handler: {action, index in
            self.editRow = indexPath.row
            self.performSegue(withIdentifier: "addShoppingListSegue", sender: nil)
        })
        
        edit.backgroundColor = .blue
        
        return [delete, edit]
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chooseListSegue" {
            let destination = segue.destination as! PickedGroceryListTableViewController
            destination.shoppingList = allList[self.tableView.indexPathForSelectedRow!.row]
        } else if segue.identifier == "addShoppingListSegue" && self.editRow != -1 {
            let destination = segue.destination as! NewShoppingListTableViewController
            destination.list = self.allList[editRow]
        }

        
    }
    

}
