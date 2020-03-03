//
//  ButtonTableViewCell.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Long Lee on 20/2/2020.
//  Copyright © 2020 Chak Lee. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var buttonRef: UIButton!
    
    weak var tableViewController: UITableViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func quantityTableViewControllerRef(_ controller: UITableViewController) {
        self.tableViewController = controller
    }

    @IBAction func onPressed(_ sender: Any) {
        let controller = self.tableViewController as! QuantityTableViewController
        
        switch (self.buttonRef.titleLabel!.text) {
        case "Search Nearby Shop":
            controller.searchNearByShop()
            break
        case "Find it yourself":
            controller.searchShop()
            break
        default:
            break
        }
    }
}
