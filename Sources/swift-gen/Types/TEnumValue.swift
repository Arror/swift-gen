//
//  TEnumValue.swift
//  swift-gen
//
//  Created by Arror on 2019/5/25.
//

import Foundation

public struct TEnumValue: Decodable {
    
    public let name: String
    public let value: Int
    
    private enum CodingKeys: String, CodingKey {
        case name   = "Name"
        case value  = "Value"
    }
}
