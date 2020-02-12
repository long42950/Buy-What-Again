//
//  GroceryListTableViewCell.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Long Lee on 22/11/2019.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import UIKit

class GroceryListTableViewCell: UITableViewCell {

    @IBOutlet weak var chosenLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
