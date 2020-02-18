//
//  ListTypeTableViewController.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Long Lee on 17/2/2020.
//  Copyright © 2020 Chak Lee. All rights reserved.
//

import UIKit

class ListTypeTableViewController: UITableViewController {
    
    weak var tableViewController: UITableViewController?
    
    var listType: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listType", for: indexPath)

        if (indexPath.row == 0) {
            cell.textLabel?.text = "Regular"
            if let type = self.listType {
                if type {
                    cell.accessoryType = .checkmark
                }
            }
        }
        else {
            cell.textLabel?.text = "Temproary"
            if let type = self.listType {
                if !type {
                    cell.accessoryType = .checkmark
                }
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = self.tableViewController as! NewShoppingListTableViewController
        if (indexPath.row == 0) {
            controller.regularList = true
        }
        else {
            controller.regularList = false
        }
        navigationController?.popViewController(animated: true)
        
    }

}
