//
//  SelectionTableViewCell.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Long Lee on 12/2/2020.
//  Copyright © 2020 Chak Lee. All rights reserved.
//

import UIKit

class SelectionTableViewCell: UITableViewCell {

    @IBOutlet weak var selectionRef: UILabel!
    @IBOutlet weak var decisionRef: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
