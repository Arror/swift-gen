//
//  TEnumValue.swift
//  swift-gen
//
//  Created by Arror on 2019/5/25.
//

import Foundation

struct TEnumValue: Decodable {
    
    let name: String
    let value: Int
    
    private enum CodingKeys: String, CodingKey {
        case name   = "Name"
        case value  = "Value"
    }
}
