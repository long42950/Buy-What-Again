//
//  AddressDetail.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Long Lee on 5/3/2020.
//  Copyright © 2020 Chak Lee. All rights reserved.
//

import Foundation

class AddressDetail: NSObject, Codable {
    var html: [String]?
    var result: [ResultData]?
    var status: String?
    
    private enum CodingKeys: String, CodingKey {
        case html = "html_attributions"
        case result = "result"
    }
}
