//
//  ItemList.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 15/6/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import Foundation

class ItemList: NSObject {
    var id: String?
    var backupKey: String?
    var listItems: [ListItem] = []
}
