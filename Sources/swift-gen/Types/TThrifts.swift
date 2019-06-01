//
//  TThrifts.swift
//  swift-gen
//
//  Created by Arror on 2019/5/26.
//

import Foundation

struct TThrifts: Decodable {
    
    let input: String
    let output: String
    let thrifts: [String: TThrift]
    let version: String
    let clientNamespcae: String
    let serverNamespace: String
    
    private enum CodingKeys: String, CodingKey {
        case input      = "IP"
        case output     = "OP"
        case thrifts    = "TS"
        case version    = "TV"
        case clientNamespcae = "CNS"
        case serverNamespace = "SNS"
    }
}
