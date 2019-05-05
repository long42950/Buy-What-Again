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
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    //This fetch all the list for a user
    func onShoppingListChange(change: DatabaseChange, shoppList: [ShoppingList])
    //This fetch all the groceries listed in a shopping list
    func onGroceriesListChange(change: DatabaseChange, groceriesList: [Grocery])
    //This fetch all the selectable items in the item list
    func onItemListChange(change: DatabaseChange, itemList: [Item])
}

protocol DatabaseProtocol: AnyObject {
    func addList(name: String, type: String, deadLine: Date?) -> ShoppingList
    func addItem(name: String) -> Item
    func addGrocery(_ name: String, _ quantity: Float, _ unit: String) -> Grocery
    func addItemToGrocery(_ item: Item, _ grocery: Grocery) -> Bool
    func addGroceryToList(list: ShoppingList, quantity: Float, unit: String, item: Item) -> Bool
    func removeList(list: ShoppingList)
    func removeItem(item: Item)
    func removeGrocery(_ grocery: Grocery)
    func removeGroceryFromList(grocery: Grocery, list: ShoppingList)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func saveContext()
}
