//
//  BackupKey+CoreDataProperties.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 17/6/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//
//

import Foundation
import CoreData


extension BackupKey {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BackupKey> {
        return NSFetchRequest<BackupKey>(entityName: "BackupKey")
    }

    @NSManaged public var code: String?

}
