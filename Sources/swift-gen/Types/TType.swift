//
//  TType.swift
//  swift-gen
//
//  Created by Arror on 2019/5/25.
//

import Foundation

struct TType: Decodable {
    
    struct TValueType: Decodable {
        
        let name: String
        
        private enum CodingKeys: String, CodingKey {
            case name = "Name"
        }
    }
    
    let name: String
    let valueType: Optional<TValueType>
    
    private enum CodingKeys: String, CodingKey {
        case name       = "Name"
        case valueType  = "ValueType"
    }
}
