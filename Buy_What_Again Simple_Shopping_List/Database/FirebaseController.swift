//  FirebaseController.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 15/6/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

//Copyright 2019 Google
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

import Foundation
//import Firebase

class FirebaseController: NSObject {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    //var authController: Auth
    //var database: Firestore
    //var itemsRef: CollectionReference?
    //var itemListsRef: CollectionReference?
    
    var itemList: [ListItem]
    var list: ItemList
    
    override init() {
        /*
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
         */
        itemList = [ListItem]()
        list = ItemList()
        super.init()
        /*
        authController.signInAnonymously() { (authResult, error) in
            guard authResult != nil else {
                fatalError("Firebase authentication failed")
            }

        }
         */
        self.setUpListeners()
    }
    
    //Retrieve the collections' reference from Firebase
    func setUpListeners() {
        /*
        itemsRef = database.collection("items")
        
        itemListsRef = database.collection("itemlists")
         */
    }
    
    func getItemByID(reference: String) -> ListItem? {
        for item in itemList {
            if item.id == reference {
                return item
            }
        }
        
        return nil
    }
    /*
    func addItem(name: String) -> DocumentReference {
        let id = itemsRef?.addDocument(data: ["name": name])
        return id!
    }
     
    
    func addList(key: String, listItemRef: [DocumentReference]) -> ItemList {
        let list = ItemList()
        let id = itemListsRef?.addDocument(data: ["items": listItemRef, "backupKey": key])
        list.backupKey = key
        list.id = id!.documentID
        
        return list
    }
     */
    
    func addItemToList(item: ListItem, list: ItemList) -> Bool {
        /*
        guard let item = getItemByID(reference: item.id!) else {
            return false
        }
        
        list.listItems.append(item)
        
        let newItemref = itemsRef!.document(item.id!)
        itemListsRef?.document(list.id!).updateData(["items" : FieldValue.arrayUnion([newItemref])])
        return true
        */
        return true
    }
    
    func deleteListItem(item: ListItem) {
        //itemsRef?.document(item.id!).delete()
    }
    
    func deleteList(list: ItemList) {
        print("\(list.id)")
        //itemListsRef?.document(list.id!).delete()
    }
    
    //Record a backup list with the corresponding backup key
    func fetchListByKey(key: String) {
        /*
        self.itemListsRef?.getDocuments { (docs, err) in
            if let err = err {
                print("\(err)")
            } else {
                if let docs = docs, docs.count > 0 {
                    for doc in docs.documents {
                        print(doc.get("backupKey"))
                        let backupKey = doc.get("backupKey") as! String
                        if backupKey == key {
                            let id = doc.documentID
                            let itemsRef = doc.get("items") as! [DocumentReference]
                            var list = ItemList()
                            list.id = id
                            list.backupKey = backupKey
                            for ref in itemsRef {
                                self.fetchlistItem(ref: ref, completion: {item in
                                    if let item = item {
                                        list.listItems.append(item)
                                        self.list = list
                                        self.itemList = list.listItems
                                    }
                                    else {
                                        self.list = list
                                    }
                                })
                                
                            }
                        }
                    }
                }
            }
        }
        */
        
    }
    
    //Create a backup list on Firebase
    func backupList(key: String, items: [Item]) -> Bool {
        /*
        self.fetchListByKey(key: key)
        if let key = self.list.backupKey {
            print(key)
            return false
        }
        var listItems: [DocumentReference] = []
        for item in items {
            let itemRef = self.addItem(name: item.name!)
            listItems.append(itemRef)
        }
        self.list = self.addList(key: key, listItemRef: listItems)
        
        return true
        */
        return true
    }
    
    //Remove an existing backup list with the corresponding backup key
    func removeBackupList(key: String) -> Bool{
        self.fetchListByKey(key: key)
        if let _ = self.list.backupKey {
            for item in self.list.listItems {
                self.deleteListItem(item: item)
            }
            self.deleteList(list: self.list)
            self.itemList = []
            self.list = ItemList()
            return true
        } else {
            return false
        }
    }
    
    //Record all items in a backup list when a list is found
    /*
    func fetchlistItem(ref: DocumentReference, completion: @escaping (ListItem?) ->()) {
        var item: ListItem?
        self.itemsRef?.getDocuments { (docs, err) in
            if let err = err {
                print("\(err)")
                completion(nil)
            } else {
                if let docs = docs {
                    for doc in docs.documents {
                        if doc.reference == ref {
                            item = ListItem()
                            item!.id = doc.documentID
                            item!.name = doc.get("name") as! String
                            completion(item!)
                        }
                    }
                }
            }
        }
    }
     */
    
    //Return the item list as an array of String
    func getList() -> [String] {
        var rtnList: [String] = []
        for listItem in self.itemList {
            rtnList.append(listItem.name!)
        }
        return rtnList
    }
}
