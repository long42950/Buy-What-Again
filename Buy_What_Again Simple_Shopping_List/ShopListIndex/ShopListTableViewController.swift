//
//  ShopListTableViewController.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 6/5/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import UIKit

class ShopListTableViewController: UITableViewController, DatabaseListener {
    
    var allShop: [Shop] = []
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
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
    
    var listenerType = ListenerType.shop
    
    func onItemListChange(change: DatabaseChange, itemList: [Item]) {
        //not used
    }
    
    func onGroceriesListChange(change: DatabaseChange, groceriesList: [Grocery]) {
        //not used
    }
    
    func onShoppingListChange(change: DatabaseChange, shoppList: [ShoppingList]) {
        //not used
    }
    //Fetch the Shop list from CoreData
    func onShopListChange(change: DatabaseChange, shopList: [Shop]) {
        self.allShop = shopList
    }
    
    func onKeyChange(change: DatabaseChange, key: [BackupKey]) {
        //not used
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allShop.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let shopCell = tableView.dequeueReusableCell(withIdentifier: "shopCell", for: indexPath)

        shopCell.textLabel?.text = allShop[indexPath.row].name

        return shopCell
    }
    
    //Create a delete action for each cell to delete a Shop
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "delete", handler: {action, index in
            let deleteShop = self.allShop[indexPath.row]
            self.allShop.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            let _ = self.databaseController?.removeShop(shop: deleteShop)
            self.databaseController?.saveContext()
        })
        
        delete.backgroundColor = .red
        
        return [delete]
    }
    
    @IBAction func onAddShop(_ sender: Any) {
        let alertController = UIAlertController(title: "New Shop", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Add", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction) in
            if let textField = alertController.textFields {
                let name = textField[0].text
                if name != "" {

                    let _ = self.databaseController?.addShop(name: name!)
                    self.databaseController!.saveContext()
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.displayMessage(title: "Error", message: "Invalid shop name")
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }))
        alertController.addTextField { textField in
            textField.placeholder = "Shop Name"
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
    
}
