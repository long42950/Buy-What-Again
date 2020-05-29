//
//  AddNewShopViewController.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 14/6/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import UIKit

class AddNewShopViewController: UIViewController, DatabaseListener {
    
    weak var databaseController: DatabaseProtocol?

    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    //Add new shop to the Shop list, a name is needed to add the custom shop
    @IBAction func onAddShop(_ sender: Any) {
        self.addNewShop()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
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
    
    func onShopListChange(change: DatabaseChange, shopList: [Shop]) {
        //not used
    }
    
    func onKeyChange(change: DatabaseChange, key: [BackupKey]) {
        //not used
    }
    
    //Show user a message with the alert message box
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style:
            UIAlertAction.Style.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addNewShop() {
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
        }))
        alertController.addTextField { textField in
            textField.placeholder = "Shop Name"
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style:
            UIAlertAction.Style.destructive, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }

}
