//
//  CoreDataController.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 5/5/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import Foundation
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistantContainer: NSPersistentContainer
    
    var allListsFetchedResultsController: NSFetchedResultsController<ShoppingList>?
    var allGroceriesFetchedResultsController: NSFetchedResultsController<Grocery>?
    var allItemFetchedResultsController: NSFetchedResultsController<Item>?
    
    override init() {
        persistantContainer = NSPersistentContainer(name: "ShoppingLists")
        persistantContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load CoreData stack: \(error)")
            }
        }
        
        super.init()
    }
    
    func saveContext() {
        if persistantContainer.viewContext.hasChanges {
            do {
                try persistantContainer.viewContext.save()
            } catch {
                fatalError("Failed to save data to CoreData: \(error)")
            }
        }
    }
    
    //TODO: 1 validation required, check for CoreData #01 task in trello
    func addList(name: String, type: String, deadLine: Date) -> ShoppingList {
        let list = NSEntityDescription.insertNewObject(forEntityName: "ShoppingList", into: persistantContainer.viewContext) as! ShoppingList
        list.name = name
        list.type = type
        if deadLine != nil {
            list.deadline = deadLine as! NSDate
        } else {
            list.deadline = nil
        }

        return list
    }
    
    //TODO: 1 validation required, check for CoreData #02 task in trello
    func addItem(name: String) -> Item {
        let item = NSEntityDescription.insertNewObject(forEntityName: "Item", into:
            persistantContainer.viewContext) as! Item
        item.name = name

        return item
    }

    func addGroceryToList(list: ShoppingList, quantity: Float, unit: String, item: Item) -> Bool {
        let grocery = addGrocery(item.name!, quantity, unit)
        saveContext()
        let _ = addItemToGrocery(item, grocery)
        saveContext()
        list.addToGroceries(grocery)
        return true
    }
    
    internal func addGrocery(_ name: String, _ quantity: Float, _ unit: String) -> Grocery {
        let grocery = NSEntityDescription.insertNewObject(forEntityName: "Grocery", into:
            persistantContainer.viewContext) as! Grocery
        grocery.name = name
        grocery.quantity = quantity
        grocery.unit = unit
        
        return grocery
    }
    
    internal func addItemToGrocery(_ item: Item, _ grocery: Grocery) -> Bool {
        grocery.items = item
        return true
    }
    
    func removeList(list: ShoppingList) {
        persistantContainer.viewContext.delete(list)
    }
    
    func removeItem(item: Item) {
        persistantContainer.viewContext.delete(item)
    }
    
    //This method will only be used after the validation for removeGroceryFromList
    //is implemented,
    internal func removeGrocery(_ grocery: Grocery) {
        persistantContainer.viewContext.delete(grocery)
    }
    
    //TODO: 1 validation required, check for CoreData #03 task in trello
    func removeGroceryFromList(grocery: Grocery, list: ShoppingList) {
        list.removeFromGroceries(grocery)
        //removeGrocery(grocery)
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        switch listener.listenerType {
        case .list:
            listener.onShoppingListChange(change: .update, shoppList: fetchAllList())
        case .grocery:
            listener.onGroceriesListChange(change: .update, groceriesList: fetchAllGrocery())
        case .item:
            listener.onItemListChange(change: .update, itemList: fetchAllItem())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func fetchAllList() -> [ShoppingList] {
        if allListsFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<ShoppingList> = ShoppingList.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            allListsFetchedResultsController = NSFetchedResultsController<ShoppingList>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            allListsFetchedResultsController?.delegate = self
            
            do {
                try allListsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        
        var lists = [ShoppingList]()
        if allListsFetchedResultsController?.fetchedObjects != nil {
            lists = (allListsFetchedResultsController?.fetchedObjects)!
        }
        
        return lists
    }
    
    func fetchAllGrocery() -> [Grocery] {
        if allGroceriesFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Grocery> = Grocery.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            allGroceriesFetchedResultsController = NSFetchedResultsController<Grocery>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            allGroceriesFetchedResultsController?.delegate = self
            
            do {
                try allGroceriesFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        
        var groceries = [Grocery]()
        if allGroceriesFetchedResultsController?.fetchedObjects != nil {
            groceries = (allGroceriesFetchedResultsController?.fetchedObjects)!
        }
        
        return groceries
    }
    
    func fetchAllItem() -> [Item] {
        if allItemFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            allItemFetchedResultsController = NSFetchedResultsController<Item>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            allItemFetchedResultsController?.delegate = self
            
            do {
                try allItemFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        
        var items = [Item]()
        if allItemFetchedResultsController?.fetchedObjects != nil {
            items = (allItemFetchedResultsController?.fetchedObjects)!
        }
        
        return items
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allListsFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == .list {
                    listener.onShoppingListChange(change: .update, shoppList: fetchAllList())
                }
            }
        }
        else if controller == allItemFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == .item {
                    listener.onItemListChange(change: .update, itemList: fetchAllItem())
                }
            }
        }
        
        else if controller == allGroceriesFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == .grocery {
                    listener.onGroceriesListChange(change: .update, groceriesList: fetchAllGrocery())
                }
            }
        }
    }
    
}
