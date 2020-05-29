//
//  ResultData.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Long Lee on 6/3/2020.
//  Copyright © 2020 Chak Lee. All rights reserved.
//

import Foundation

class ResultData: NSObject, Codable {
    var addressComponent: [AddressComponent]?
    
    private enum CodingKeys: String, CodingKey {
        case addressComponent = "address_components"
    }
}
