//
//  TThrift.swift
//  swift-gen
//
//  Created by Arror on 2019/5/26.
//

import Foundation

public struct TThrift: Decodable {
    
    public let enums: [String: TEnum]
    public let structs: [String: TStruct]
    public let services: [String: TService]
    
    private enum CodingKeys: String, CodingKey {
        case enums      = "Enums"
        case structs    = "Structs"
        case services   = "Services"
    }
}
