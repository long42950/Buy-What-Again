//
//  PlaceData.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 12/6/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import Foundation

class PlaceData: NSObject, Decodable {
    var placeID: String
    
    private enum RootKeys: String, CodingKey {
        case candidates
    }
    
    private enum PlaceKeys: String, CodingKey {
        case placeID = "place_id"
    }
    
    required init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
        let placeContainer = try rootContainer.nestedContainer(keyedBy: PlaceKeys.self, forKey: .candidates)
        self.placeID = try placeContainer.decode(String.self, forKey: .placeID)
    }
}
