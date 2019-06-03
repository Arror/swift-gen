//
//  TField.swift
//  swift-gen
//
//  Created by Arror on 2019/5/25.
//

import Foundation

public struct TField: Decodable {
    
    public let id: Int
    public let name: String
    public let isOptional: Bool
    public let type: Optional<TType>
    
    private enum CodingKeys: String, CodingKey {
        case id         = "ID"
        case name       = "Name"
        case isOptional = "Optional"
        case type       = "Type"
    }
}
