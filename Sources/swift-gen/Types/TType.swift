//
//  TType.swift
//  swift-gen
//
//  Created by Arror on 2019/5/25.
//

import Foundation

struct TType: Codable {
    
    struct TKeyType: Codable {
        
        let name: String
        
        private enum CodingKeys: String, CodingKey {
            case name = "Name"
        }
    }
    
    struct TValueType: Codable {
        
        let name: String
        
        private enum CodingKeys: String, CodingKey {
            case name = "Name"
        }
    }
    
    let name: String
    let keyType: Optional<TKeyType>
    let valueType: Optional<TValueType>
    
    private enum CodingKeys: String, CodingKey {
        case name       = "Name"
        case keyType    = "KeyType"
        case valueType  = "ValueType"
    }
}
