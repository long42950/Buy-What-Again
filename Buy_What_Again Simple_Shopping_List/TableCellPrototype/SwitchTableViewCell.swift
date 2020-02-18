//
//  ButtonTableViewCell.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Long Lee on 12/2/2020.
//  Copyright © 2020 Chak Lee. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {
    
    weak var tableViewControllerRef: UITableViewController?
    enum refError: Error {
        case OccupiedReference
    }

    @IBOutlet weak var switchRef: UISwitch!
    @IBOutlet weak var dateLabelRef: UILabel!
    
    var dateFormatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.dateFormatter.dateFormat = "d MMM, yyy HH:mm"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func checkStatus(_ sender: Any) {
        print(switchRef.isEnabled)
        self.loadDate()
    }
    
    func newShoppingListRef(_ tableViewController: UITableViewController) {
        self.tableViewControllerRef = tableViewController as! NewShoppingListTableViewController
    }
    
    private func currentTableView() -> Int {
        switch self.tableViewControllerRef {
            case is NewShoppingListTableViewController:
                return 0
            default:
                return -1
        }
    }
    
    private func showDateTimePicker() {
        let controller = self.tableViewControllerRef as! NewShoppingListTableViewController
        controller.tableView.reloadData()
    }
    
    func loadDate() {
        if !(self.switchRef.isOn) {
            self.dateLabelRef.isHidden = true
        }
        else {
            let controller = self.tableViewControllerRef as! NewShoppingListTableViewController
            self.dateLabelRef.isHidden = false
            let dateRef = controller.datePickerCell as! DateTimeTableViewCell
            self.dateLabelRef.text = dateFormatter.string(from: dateRef.dateTimeRef.date)
        }
        switch self.currentTableView() {
            case 0:
                self.showDateTimePicker()
                break
            default:
                break
        }
    }

}
