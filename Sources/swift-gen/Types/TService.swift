//
//  TService.swift
//  swift-gen
//
//  Created by Arror on 2019/5/26.
//

import Foundation

public struct TService: Decodable {
    
    public let name: String
    public let methods: [String: TMethod]
    
    private enum CodingKeys: String, CodingKey {
        case name       = "Name"
        case methods    = "Methods"
    }
}
