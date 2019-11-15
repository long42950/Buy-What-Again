//
//  GroceryTableViewCell.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 8/6/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import UIKit

class GroceryTableViewCell: UITableViewCell {

    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var groceryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
