//
//  TService.swift
//  swift-gen
//
//  Created by Arror on 2019/5/26.
//

import Foundation

struct TService: Decodable {
    
    let name: String
    let methods: [String: TMethod]
    
    private enum CodingKeys: String, CodingKey {
        case name       = "Name"
        case methods    = "Methods"
    }
}
