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
    var allShopFetchedResultsController: NSFetchedResultsController<Shop>?
    var keyFetchedResultsController: NSFetchedResultsController<BackupKey>?
    
    override init() {
        persistantContainer = NSPersistentContainer(name: "ShoppingLists")
        persistantContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load CoreData stack: \(error)")
            }
        }
        
        super.init()
        
        if fetchAllItem().count == 0 {
            createDefaultitem()
        }
        
        if fetchAllShop().count == 0 {
            createDefaultShopList()
        }
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
    func addList(name: String, type: String, deadLine: Date?) -> ShoppingList {
        let list = NSEntityDescription.insertNewObject(forEntityName: "ShoppingList", into: persistantContainer.viewContext) as! ShoppingList
        list.name = name
        list.type = type
        if deadLine != nil {
            list.deadline = deadLine! as NSDate
        }
        else {
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
    
    func editList(name: String, type: String, deadLine: Date?, list: ShoppingList) -> (Bool, Error?) {
        do {
            var oldList = try persistantContainer.viewContext.existingObject(with: list.objectID) as! ShoppingList
            oldList.name = name
            oldList.type = type
            if let deadline = deadLine {
                oldList.deadline = deadline as NSDate
            } else {
                oldList.deadline = nil
            }
            return (true, nil)
        } catch let error {
            print("Error: \(error.localizedDescription)")
            return (false, error)
        }
    }
    
    func test() {}

    func addGroceryToList(list: ShoppingList, quantity: Float, unit: String, item: Item, shopPlaceId: String?, street: String?, suburb: String?, state: String?, postcode: String?, preferShop: Shop?) -> Bool {
        let grocery = addGrocery(item.name!, quantity, unit, shopPlaceId, street, suburb, state, postcode, preferShop)
        saveContext()
        let _ = addItemToGrocery(item, grocery)
        saveContext()
        list.addToGroceries(grocery)
        return true
    }
    
    internal func addGrocery(_ name: String, _ quantity: Float, _ unit: String, _ shopPlaceId: String?, _ street: String?, _ suburb: String?, _ state: String?, _ postcode: String?, _ preferShop: Shop?) -> Grocery {
        let grocery = NSEntityDescription.insertNewObject(forEntityName: "Grocery", into:
            persistantContainer.viewContext) as! Grocery
        grocery.name = name
        grocery.quantity = quantity
        grocery.unit = unit
        grocery.isBought = false
        grocery.shopPlaceId = shopPlaceId
        grocery.street = street
        grocery.suburb = suburb
        grocery.state = state
        grocery.postcode = postcode
        if let preferShop = preferShop {
            preferShop.addToGroceries(grocery)
            grocery.shops = preferShop
        }
        
        return grocery
    }
    
    func editGrocery(name: String, quantity: Float, unit: String, shopPlaceId: String?,  street: String?,  suburb: String?,  state: String?,  postcode: String?, preferShop: Shop?, grocery: Grocery) -> (Bool, Error?) {
        do {
            let oldGrocery = try persistantContainer.viewContext.existingObject(with: grocery.objectID) as! Grocery
            oldGrocery.name = name
            oldGrocery.quantity = quantity
            oldGrocery.unit = unit
            oldGrocery.isBought = false
            oldGrocery.shopPlaceId = shopPlaceId
            oldGrocery.street = street
            oldGrocery.suburb = suburb
            oldGrocery.state = state
            oldGrocery.postcode = postcode
            if let preferShop = preferShop {
                if let oldShop = oldGrocery.shops {
                    oldShop.removeFromGroceries(oldGrocery)
                }
                preferShop.addToGroceries(oldGrocery)
                grocery.shops = preferShop
            }
            return (true, nil)
        } catch let error {
            print("Error: \(error.localizedDescription)")
            return (false, error)
        }
    }
    
    func editGroceryStatus(isBought: Bool, grocery: Grocery) -> (Grocery, Error?) {
        do {
            let editGrocery = try persistantContainer.viewContext.existingObject(with: grocery.objectID) as! Grocery
            editGrocery.isBought = isBought
            return (editGrocery, nil)
        } catch let error {
            print("Error: \(error.localizedDescription)")
            return (grocery, error)
        }
        
    }
    
    func addShop(name: String) -> Shop {
        let shop = NSEntityDescription.insertNewObject(forEntityName: "Shop", into: persistantContainer.viewContext) as! Shop
        shop.name = name
        
        return shop
    }
    
    internal func addItemToGrocery(_ item: Item, _ grocery: Grocery) -> Bool {
        grocery.items = item
        return true
    }
    
    func addKey(key: String) -> BackupKey {
        let backupKey = NSEntityDescription.insertNewObject(forEntityName: "BackupKey", into: persistantContainer.viewContext) as! BackupKey
        backupKey.code = key
        
        return backupKey
    }
    
    func removeList(list: ShoppingList) {
        if let groceries = list.groceries {
            for grocery in groceries {
                self.removeGrocery(grocery as! Grocery)
            }
        }
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
    
    func removeShop(shop: Shop) {
        persistantContainer.viewContext.delete(shop)
    }
    
    //TODO: 1 validation required, check for CoreData #03 task in trello
    func removeGroceryFromList(grocery: Grocery, list: ShoppingList) {
        list.removeFromGroceries(grocery)
        removeGrocery(grocery)
    }
    
    func removeKey(key: BackupKey) {
        persistantContainer.viewContext.delete(key)
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
            listener.onKeyChange(change: .update, key: fetchBackupKey())
        case .shop:
            listener.onShopListChange(change: .update, shopList: fetchAllShop())
            
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
    
    func fetchAllShop() -> [Shop] {
        if allShopFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Shop> = Shop.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            allShopFetchedResultsController = NSFetchedResultsController<Shop>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            allShopFetchedResultsController?.delegate = self
            
            do {
                try allShopFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        
        var shops = [Shop]()
        if allShopFetchedResultsController?.fetchedObjects != nil {
            shops = (allShopFetchedResultsController?.fetchedObjects)!
        }
        
        return shops
    }
    
    func fetchBackupKey() -> [BackupKey] {
        if keyFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<BackupKey> = BackupKey.fetchRequest()
            fetchRequest.sortDescriptors = []
            keyFetchedResultsController = NSFetchedResultsController<BackupKey>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            keyFetchedResultsController?.delegate = self
            
            do {
                try keyFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        
        var key = [BackupKey]()
        if keyFetchedResultsController?.fetchedObjects != nil {
            key = (keyFetchedResultsController?.fetchedObjects)!
        }
        
        return key
        
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
        
        else if controller == allShopFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == .shop {
                    listener.onShopListChange(change: .update, shopList: fetchAllShop())
                }
            }
        }
    }
    
    func createDefaultitem() {
        let _ = addItem(name: "Apple")
        let _ = addItem(name: "Apple Pie")
        let _ = addItem(name: "Bread")
        let _ = addItem(name: "Canned fish")
        let _ = addItem(name: "Dog food")
        let _ = addItem(name: "Mountain Dew")
        self.saveContext()
    }
    
    func createDefaultShopList() {
        let _ = addShop(name: "Coles")
        let _ = addShop(name: "Woolworths")
        let _ = addShop(name: "ALDI")
        let _ = addShop(name: "IGA")
        let _ = addShop(name: "Costco")
        let _ = addShop(name: "7-11")
        self.saveContext()
    }
    
}
