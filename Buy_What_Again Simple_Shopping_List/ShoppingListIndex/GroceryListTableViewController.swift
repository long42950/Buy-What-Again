//
//  GroceryListTableViewController.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 6/5/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import UIKit

class GroceryListTableViewController: UITableViewController, DatabaseListener, UISearchResultsUpdating {

    
    var newItem = false
    var shoppingList: ShoppingList?
    
    var allItem: [Item] = []
    var filteredItem: [Item] = []
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Grocery"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text?.lowercased(), searchText.count > 0 {
            filteredItem = allItem.filter({(item: Item) -> Bool in
                return item.name!.lowercased().contains(searchText)
            })
        }
        else {
            filteredItem = allItem
        }
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        newItem = false
        databaseController?.addListener(listener: self)
        self.tableView.reloadData()
        
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
        filteredItem = allItem
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
        return filteredItem.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! GroceryListTableViewCell
        
        let item = filteredItem[indexPath.row]
        itemCell.textLabel?.text = item.name
        if let glist = item.groceries, glist.count > 0 {
            for grocery in glist {
                if (grocery as! Grocery).shoppinglists! == self.shoppingList {
                    itemCell.chosenLabel?.text = "Chosen!"
                    break
                }
            }
        }
        else {
            itemCell.chosenLabel?.text = ""
        }
        
        return itemCell
    }
    
    @IBAction func onAddItem(_ sender: Any) {
        let alertController = UIAlertController(title: "New Item", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Add", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction) in
            if let textField = alertController.textFields {
                let name = textField[0].text
                if name != "" {

                    let _ = self.databaseController?.addItem(name: name!)
                    self.databaseController!.saveContext()
                    self.newItem = true
                    self.performSegue(withIdentifier: "addGrocerySegue", sender: nil)
                } else {
                    self.displayMessage(title: "Error", message: "Invalid item name")
                }
            }

            
        }))
        alertController.addTextField { textField in
            textField.placeholder = "Item Name"
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style:
            UIAlertAction.Style.destructive, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //Show user a message with the alert message box
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style:
            UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addGrocerySegue" {
            let destination = segue.destination as! QuantityTableViewController	
            destination.shoppingList = self.shoppingList
            if newItem {
                destination.item = allItem[allItem.count-1]
            } else {
                destination.item = allItem[tableView.indexPathForSelectedRow!.row]
            }
            destination.title = destination.item!.name
        }
    }
    

}
