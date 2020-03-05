//
//  TextTableViewCell.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Long Lee on 12/2/2020.
//  Copyright © 2020 Chak Lee. All rights reserved.
//

import UIKit

class TextTableViewCell: UITableViewCell {

    @IBOutlet weak var textRef: UITextField!
    
    weak var tableViewController: UITableViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.textRef.addTarget(self, action: #selector(onTextChange), for: .editingChanged)
    }
    
    @objc private func onTextChange() {
        self.reuseIdentifier
        
        if let tableViewController = self.tableViewController {
            let controller = tableViewController as! QuantityTableViewController
            
            switch self.textRef.placeholder {
            case "Amount":
                controller.tempQuantity = self.textRef.text
                break
            case "Street":
                controller.tempAddress.street = self.textRef.text
                break
            case "Suburb":
                controller.tempAddress.suburb = self.textRef.text
                break
            case "State":
                controller.tempAddress.state = self.textRef.text
                break
            case "Postcode":
                controller.tempAddress.postcode = self.textRef.text
                break
            default:
                break
            }
        }
    }
    
    func quantityTableViewControllerRef(_ controller: UITableViewController) {
        self.tableViewController = controller
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
