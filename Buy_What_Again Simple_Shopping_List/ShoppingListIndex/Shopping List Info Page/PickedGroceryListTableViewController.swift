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

        self.navigationItem.title = shoppingList!.name
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
    
    var listenerType = ListenerType.grocery
    
    func onItemListChange(change: DatabaseChange, itemList: [Item]) {
        //not used
    }
    
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        displayMessage(title: "debug", message: "\(groceryList[indexPath.row].quantity)")
    }
    
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
        
        let done = UITableViewRowAction(style: .normal, title: "done", handler: {action, index in
            let broughtGrocery = self.groceryList[indexPath.row]
            broughtGrocery.isBought =  true
            self.databaseController?.saveContext()
        })
        
        done.backgroundColor = .blue
        
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chooseGrocerySegue" {
            let desination = segue.destination as! GroceryListTableViewController
            desination.shoppingList = self.shoppingList
        }
    }
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}
