//
//  TMethod.swift
//  swift-gen
//
//  Created by Arror on 2019/5/26.
//

import Foundation

public struct TMethod: Decodable {
    
    public let name: String
    public let returnType: Optional<TType>
    public let arguments: [TField]
    
    private enum CodingKeys: String, CodingKey {
        case name       = "Name"
        case returnType = "ReturnType"
        case arguments  = "Arguments"
    }
}
