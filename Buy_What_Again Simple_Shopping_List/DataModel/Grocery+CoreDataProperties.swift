//
//  Grocery+CoreDataProperties.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 15/6/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
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
    @NSManaged public var shopAddress: String?
    @NSManaged public var shopPlaceId: String?
    @NSManaged public var unit: String?
    @NSManaged public var items: Item?
    @NSManaged public var shoppinglists: ShoppingList?
    @NSManaged public var shops: Shop?

}
