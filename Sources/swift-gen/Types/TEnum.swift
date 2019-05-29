//
//  TEnum.swift
//  swift-gen
//
//  Created by Arror on 2019/5/25.
//

import Foundation

struct TEnum: Decodable {
    
    let name: String
    let values: [String: TEnumValue]
    
    private enum CodingKeys: String, CodingKey {
        case name   = "Name"
        case values = "Values"
    }
}
