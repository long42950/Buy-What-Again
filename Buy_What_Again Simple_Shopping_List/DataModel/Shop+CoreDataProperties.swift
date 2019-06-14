//
//  Shop+CoreDataProperties.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 14/6/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//
//

import Foundation
import CoreData


extension Shop {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Shop> {
        return NSFetchRequest<Shop>(entityName: "Shop")
    }

    @NSManaged public var name: String?
    @NSManaged public var groceries: Grocery?

}
