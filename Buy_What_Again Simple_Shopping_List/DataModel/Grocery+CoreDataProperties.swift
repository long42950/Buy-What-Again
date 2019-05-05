//
//  Grocery+CoreDataProperties.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 5/5/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//
//

import Foundation
import CoreData


extension Grocery {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Grocery> {
        return NSFetchRequest<Grocery>(entityName: "Grocery")
    }

    @NSManaged public var quantity: Float
    @NSManaged public var unit: String?
    @NSManaged public var name: String?
    @NSManaged public var items: Item?
    @NSManaged public var shoppinglists: ShoppingList?

}
