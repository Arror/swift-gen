//
//  TType.swift
//  swift-gen
//
//  Created by Arror on 2019/5/25.
//

import Foundation

public struct TType: Decodable {
    
    public struct TValueType: Decodable {
        
        public let name: String
        
        private enum CodingKeys: String, CodingKey {
            case name = "Name"
        }
    }
    
    public let name: String
    public let valueType: Optional<TValueType>
    
    private enum CodingKeys: String, CodingKey {
        case name       = "Name"
        case valueType  = "ValueType"
    }
}
