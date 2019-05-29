//
//  TField.swift
//  swift-gen
//
//  Created by Arror on 2019/5/25.
//

import Foundation

struct TField: Decodable {
    
    let id: Int
    let name: String
    let isOptional: Bool
    let type: Optional<TType>
    
    private enum CodingKeys: String, CodingKey {
        case id         = "ID"
        case name       = "Name"
        case isOptional = "Optional"
        case type       = "Type"
    }
}
