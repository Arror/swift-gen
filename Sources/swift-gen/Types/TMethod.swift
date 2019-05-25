//
//  TMethod.swift
//  swift-gen
//
//  Created by Arror on 2019/5/26.
//

import Foundation

struct TMethod: Codable {
    
    let name: String
    let returnType: Optional<TType>
    let arguments: [TField]
    
    private enum CodingKeys: String, CodingKey {
        case name       = "Name"
        case returnType = "ReturnType"
        case arguments  = "Arguments"
    }
}
