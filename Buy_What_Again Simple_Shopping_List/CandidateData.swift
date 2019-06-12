//
//  CandidateData.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 12/6/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import Foundation

class CandidateData: NSObject, Decodable {
    var placeIDs: [PlaceData]?
    var status: String?
    
    private enum CodingKeys: String, CodingKey {
        case placeIDs = "candidates"
        case status
    }
}
