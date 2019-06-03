//
//  TEnum.swift
//  swift-gen
//
//  Created by Arror on 2019/5/25.
//

import Foundation

public struct TEnum: Decodable {
    
    public let name: String
    public let values: [String: TEnumValue]
    
    private enum CodingKeys: String, CodingKey {
        case name   = "Name"
        case values = "Values"
    }
}
