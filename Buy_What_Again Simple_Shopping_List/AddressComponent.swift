//
//  AddressComponent.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Long Lee on 5/3/2020.
//  Copyright © 2020 Chak Lee. All rights reserved.
//

import Foundation

class AddressComponent: NSObject, Codable {
    var longName: String
    var shortName: String
    var type: [String]
    
    private enum PlaceKeys: String, CodingKey {
        case longName = "long_name"
        case shortName = "short_name"
        case types
    }
    
    required init(from decoder: Decoder) throws {
        let placeContainer = try decoder.container(keyedBy: PlaceKeys.self)
        self.longName = try placeContainer.decode(String.self, forKey: .longName)
        self.shortName = try placeContainer.decode(String.self, forKey: .shortName)
        self.type = try placeContainer.decode([String].self, forKey: .types)
    }

}


