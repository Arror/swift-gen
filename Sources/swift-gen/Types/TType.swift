//
//  TType.swift
//  swift-gen
//
//  Created by Arror on 2019/5/25.
//

import Foundation

struct TType: Codable {
    
    struct TSubType: Codable {
        
        let name: String
        
        private enum CodingKeys: String, CodingKey {
            case name = "Name"
        }
    }
    
    let name: String
    let keyType: Optional<TSubType>
    let valueType: Optional<TSubType>
    
    private enum CodingKeys: String, CodingKey {
        case name       = "Name"
        case keyType    = "KeyType"
        case valueType  = "ValueType"
    }
}
