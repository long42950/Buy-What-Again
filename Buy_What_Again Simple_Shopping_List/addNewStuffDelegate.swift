//
//  addNewStuffDelegate.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 5/5/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import Foundation

protocol AddShoppingListDelegate: AnyObject {
    func addShoppingList(newShoppingList: ShoppingList) -> Bool
}
