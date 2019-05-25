//
//  TStruct.swift
//  swift-gen
//
//  Created by Arror on 2019/5/25.
//

import Foundation

struct TStruct: Codable {
    
    let name: String
    let fields: [TField]
    
    private enum CodingKeys: String, CodingKey {
        case name   = "Name"
        case fields = "Fields"
    }
}
