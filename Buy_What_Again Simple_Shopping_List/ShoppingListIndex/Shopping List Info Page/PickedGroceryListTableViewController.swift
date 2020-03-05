//
//  PickedGroceryListTableViewController.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 6/5/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import UIKit

class PickedGroceryListTableViewController: UITableViewController, DatabaseListener {
    
    var shoppingList: ShoppingList?
    var groceryList: [Grocery] = []
    
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the navigation title to the name of the item when editing it
        self.navigationItem.title = shoppingList!.name
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceryList.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    
    @IBAction func onShowSelection(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Reset List", style: .destructive) { _ in
            self.onReset()
        })
        
        alertController.addAction(UIAlertAction(title: "Add Grocery", style: .default) { _ in
            self.performSegue(withIdentifier: "chooseGrocerySegue", sender: nil)
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true)
    }
    
    //Reset the status of all Groceries, only if all Groceries have been bought
    func onReset() {
        for grocery in self.groceryList {
            if !grocery.isBought {
                self.displayMessage(title: "Warning", message: "You still have grocery to buy!")
                return
            }
        }
        for grocery in self.groceryList {
            databaseController?.editGroceryStatus(isBought: false, grocery: grocery)
            databaseController!.saveContext()
            self.displayMessage(title: "Warning", message: "List reset!")
        }
    }
    
    var listenerType = ListenerType.grocery
    
    func onItemListChange(change: DatabaseChange, itemList: [Item]) {
        //not used
    }
    //Fetch Groceries in the corresponding list from CoreData
    func onGroceriesListChange(change: DatabaseChange, groceriesList: [Grocery]) {
        self.groceryList = []
        for grocery in groceriesList {
            if grocery.shoppinglists!.isEqual(self.shoppingList!) {
                groceryList.append(grocery)
        
            }
        }
        tableView.reloadData()
    }
    
    func onShoppingListChange(change: DatabaseChange, shoppList: [ShoppingList]) {
        //not used
    }
    
    func onShopListChange(change: DatabaseChange, shopList: [Shop]) {
        //not used
    }
    
    func onKeyChange(change: DatabaseChange, key: [BackupKey]) {
        //not used
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let groceryCell = tableView.dequeueReusableCell(withIdentifier: "groceryCell", for: indexPath) as! GroceryTableViewCell

        let grocery = groceryList[indexPath.row]
        if grocery.isBought {
            let attrString = NSAttributedString(string: grocery.name!, attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
            groceryCell.groceryLabel.attributedText = attrString
            groceryCell.quantityLabel.text = "Bought!"
            
        }
        else {
            groceryCell.groceryLabel.attributedText = nil
            groceryCell.groceryLabel.text = grocery.name
            groceryCell.quantityLabel.text = "\(grocery.quantity) \(grocery.unit!)"
        }
        

        return groceryCell
        
    }
    
    //Create delete action for each cell to delete an Item, and either the done or undo action depending on the Grocery's status
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "delete", handler: {action, index in
            let deleteGrocery = self.groceryList[indexPath.row]
            self.groceryList.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            let _ = self.databaseController?.removeGroceryFromList(grocery: deleteGrocery, list: self.shoppingList!)
            self.databaseController?.saveContext()
        })
        
        delete.backgroundColor = .red
        
        //If the Grocery hasn't been bought include this as a possible action which turn the status to bought
        let done = UITableViewRowAction(style: .normal, title: "done", handler: {action, index in
            let broughtGrocery = self.groceryList[indexPath.row]
            broughtGrocery.isBought =  true
            self.databaseController?.saveContext()
        })
        
        done.backgroundColor = .blue
        
        //If the Grocery has been bought include this as a possible action which turn the status to un-bought
        let undo = UITableViewRowAction(style: .normal, title: "un-do", handler: {action, index in
            let broughtGrocery = self.groceryList[indexPath.row]
            broughtGrocery.isBought =  false
            self.databaseController?.saveContext()
        })
        
        undo.backgroundColor = .darkGray
        if groceryList[indexPath.row].isBought {
            return [delete, undo]
        }
        
        return [delete, done]
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chooseGrocerySegue" {
            let desination = segue.destination as! GroceryListTableViewController
            desination.shoppingList = self.shoppingList
        }
        else if segue.identifier == "editGrocerySegue" {
            let destination = segue.destination as! QuantityTableViewController
            destination.currentGrocery = groceryList[(self.tableView.indexPathForSelectedRow?.row)!]
        }
    }
    
    //Show user a message with the alert message box
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}
