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
    
    @IBAction func onBeingLazy(_ sender: Any) {
        self.displayMessage(title: "Well... 🤦🏻", message: "This feature will be available soon!")
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
    
    func onShopListChange(change: DatabaseChange, shopList: [Shop]) {
        self.allShop = shopList
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allShop.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let shopCell = tableView.dequeueReusableCell(withIdentifier: "shopCell", for: indexPath)

        shopCell.textLabel?.text = allShop[indexPath.row].name

        return shopCell
    }
    

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
