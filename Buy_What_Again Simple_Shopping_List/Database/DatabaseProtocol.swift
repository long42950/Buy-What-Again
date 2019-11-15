//
//  DatabaseProtocol.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 3/5/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case item
    case grocery
    case list
    case shop
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    //This fetch all the list for a user
    func onShoppingListChange(change: DatabaseChange, shoppList: [ShoppingList])
    //This fetch all the groceries listed in a shopping list
    func onGroceriesListChange(change: DatabaseChange, groceriesList: [Grocery])
    //This fetch all the selectable items in the item list
    func onItemListChange(change: DatabaseChange, itemList: [Item])
    //This fetch all the shop in the shop list
    func onShopListChange(change: DatabaseChange, shopList: [Shop])
    //This fetch the key of a backup list
    func onKeyChange(change: DatabaseChange, key: [BackupKey])
    
}

protocol DatabaseProtocol: AnyObject {
    //Add a list to CoreData
    func addList(name: String, type: String, deadLine: Date?) -> ShoppingList
    //Edit an existing list inside CoreData
    func editList(name: String, type: String, deadLine: Date?, list: ShoppingList) -> (Bool, Error?)
    //Add an item to CoreData
    func addItem(name: String) -> Item
    //Add a grocery to CoreData
    func addGrocery(_ name: String, _ quantity: Float, _ unit: String, _ shopPlaceId: String?, _ shopAddress: String?, _ preferShop: Shop?) -> Grocery
    //Edit an existing grocery inside CoreData
    func editGrocery(name: String, quantity: Float, unit: String, shopPlaceId: String?, shopAddress: String?, preferShop: Shop?, grocery: Grocery) -> (Bool, Error?)
    //Edit an exisiting grocery's status inside CoreData
    func editGroceryStatus(isBought: Bool, grocery: Grocery) -> (Grocery, Error?)
    //Add a shop to CoreData
    func addShop(name: String) -> Shop
    //Assign an existing item to an existing grocery inside CoreData
    func addItemToGrocery(_ item: Item, _ grocery: Grocery) -> Bool
    //Assign an existing grocery to an existing shopping list inside CoreData
    func addGroceryToList(list: ShoppingList, quantity: Float, unit: String, item: Item, shopPlaceId: String?, shopAddress: String?, preferShop: Shop?) -> Bool
    //Add a backup key to CoreData
    func addKey(key: String) -> BackupKey
    //Remove an existing shopping list inside CoreData
    func removeList(list: ShoppingList)
    //Remove an existing item inside CoreData
    func removeItem(item: Item)
    //Remove an existing grocery inside CoreData
    func removeGrocery(_ grocery: Grocery)
    //Remove an existing shop inside CoreData
    func removeShop(shop: Shop)
    //Remove an existing backup key inside Coredata
    func removeKey(key: BackupKey)
    //Remove an existing grocery from an existing shopping list
    func removeGroceryFromList(grocery: Grocery, list: ShoppingList)
    //Add a database listener to the list
    func addListener(listener: DatabaseListener)
    //Remove an existing database listener from the list
    func removeListener(listener: DatabaseListener)
    //Save changes to the data inside CoreData
    func saveContext()
}
