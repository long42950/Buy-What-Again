//
//  MapTableViewCell.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Long Lee on 20/2/2020.
//  Copyright © 2020 Chak Lee. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces

class MapTableViewCell: UITableViewCell {

    @IBOutlet weak var mapRef: MKMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
