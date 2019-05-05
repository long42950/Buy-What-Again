//
//  ShoppingList+CoreDataProperties.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 5/5/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//
//

import Foundation
import CoreData


extension ShoppingList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShoppingList> {
        return NSFetchRequest<ShoppingList>(entityName: "ShoppingList")
    }

    @NSManaged public var deadline: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var status: String?
    @NSManaged public var type: String?
    @NSManaged public var groceries: NSSet?

}

// MARK: Generated accessors for groceries
extension ShoppingList {

    @objc(addGroceriesObject:)
    @NSManaged public func addToGroceries(_ value: Grocery)

    @objc(removeGroceriesObject:)
    @NSManaged public func removeFromGroceries(_ value: Grocery)

    @objc(addGroceries:)
    @NSManaged public func addToGroceries(_ values: NSSet)

    @objc(removeGroceries:)
    @NSManaged public func removeFromGroceries(_ values: NSSet)

}
