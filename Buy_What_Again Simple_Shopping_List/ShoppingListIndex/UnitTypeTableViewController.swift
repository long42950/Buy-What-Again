//
//  UnitTypeTableViewController.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Long Lee on 25/2/2020.
//  Copyright © 2020 Chak Lee. All rights reserved.
//

import UIKit

class UnitTypeTableViewController: UITableViewController {
    
    weak var tableViewController: UITableViewController?
    
    var unitType: String?

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
        return 3
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "unitType", for: indexPath)

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Kg"
            if let type = self.unitType {
                if (type == "Kg") {
                    cell.accessoryType = .checkmark
                }
            }
            break
        case 1:
            cell.textLabel?.text = "Pack"
            if let type = self.unitType {
                if (type == "Pack") {
                    cell.accessoryType = .checkmark
                }
            }
            break
        case 2:
            cell.textLabel?.text = "Each"
            if let type = self.unitType {
                if (type == "Each") {
                    cell.accessoryType = .checkmark
                }
            }
            break
        default:
            cell.textLabel?.text = "Error"
            break
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = self.tableViewController as! QuantityTableViewController
        let selectionCellRef = controller.selectionCell as! SelectionTableViewCell
        switch indexPath.row {
            case 0:
                controller.unitType = "Kg"
                selectionCellRef.decisionRef.text = "Kg"
                break
            case 1:
                controller.unitType = "Pack"
                selectionCellRef.decisionRef.text = "Pack"
                break
            case 2:
                controller.unitType = "Each"
                selectionCellRef.decisionRef.text = "Each"
                break
            default:
                break
        }
        navigationController?.popViewController(animated: true)
    }

}
