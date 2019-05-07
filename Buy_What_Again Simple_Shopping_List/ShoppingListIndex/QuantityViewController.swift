//
//  QuantityViewController.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 7/5/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import UIKit

class QuantityViewController: UIViewController, DatabaseListener {
    
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var unitSegment: UISegmentedControl!
    
    var shoppingList: ShoppingList?
    var item: Item?
    
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    var listenerType = ListenerType.grocery
    
    func onShoppingListChange(change: DatabaseChange, shoppList: [ShoppingList]) {
        //not used
    }
    
    func onGroceriesListChange(change: DatabaseChange, groceriesList: [Grocery]) {
        //not used
    }
    
    func onItemListChange(change: DatabaseChange, itemList: [Item]) {
        //not used
    }
    
    @IBAction func onAddGrocery(_ sender: Any) {
        let _ = databaseController?.addGroceryToList(list: shoppingList!, quantity: 1, unit: unitSegment.titleForSegment(at: unitSegment.selectedSegmentIndex)!, item: item!)
        databaseController!.saveContext()
        
        navigationController?.popViewController(animated: true)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
