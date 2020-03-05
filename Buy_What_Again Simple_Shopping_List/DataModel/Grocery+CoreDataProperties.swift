//
//  Grocery+CoreDataProperties.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Long Lee on 3/3/2020.
//  Copyright © 2020 Chak Lee. All rights reserved.
//
//

import Foundation
import CoreData


extension Grocery {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Grocery> {
        return NSFetchRequest<Grocery>(entityName: "Grocery")
    }

    @NSManaged public var isBought: Bool
    @NSManaged public var name: String?
    @NSManaged public var quantity: Float
    @NSManaged public var shopPlaceId: String?
    @NSManaged public var unit: String?
    @NSManaged public var street: String?
    @NSManaged public var suburb: String?
    @NSManaged public var state: String?
    @NSManaged public var postcode: String?
    @NSManaged public var items: Item?
    @NSManaged public var shoppinglists: ShoppingList?
    @NSManaged public var shops: Shop?

}
