//
//  TThrift.swift
//  swift-gen
//
//  Created by Arror on 2019/5/26.
//

import Foundation

struct TThrift: Codable {
    
    let enums: [String: TEnum]
    let structs: [String: TStruct]
    let services: [String: TService]
    
    private enum CodingKeys: String, CodingKey {
        case enums      = "Enums"
        case structs    = "Structs"
        case services   = "Services"
    }
}
