//
//  DateTimeTableViewCell.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Long Lee on 12/2/2020.
//  Copyright © 2020 Chak Lee. All rights reserved.
//

import UIKit

class DateTimeTableViewCell: UITableViewCell {
    
    weak var tableViewControllerRef: UITableViewController?
    
    let TODAY = Date()

    @IBOutlet weak var dateTimeRef: UIDatePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dateTimeRef.addTarget(self, action: #selector(onDateChange), for: .valueChanged)
        self.dateTimeRef.minimumDate = TODAY
    }
    
    @objc private func onDateChange() {
        let table = self.tableViewControllerRef as! NewShoppingListTableViewController
        table.reloadDate()
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
