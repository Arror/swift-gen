//
//  TThrifts.swift
//  swift-gen
//
//  Created by Arror on 2019/5/26.
//

import Foundation

struct TThrifts: Codable {
    
    let input: String
    let output: String
    let thrifts: [String: TThrift]
    
    private enum CodingKeys: String, CodingKey {
        case input      = "IP"
        case output     = "OP"
        case thrifts    = "TS"
    }
}
