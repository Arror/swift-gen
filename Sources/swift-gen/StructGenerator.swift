//
//  StructGenerator.swift
//  swift-gen
//
//  Created by Arror on 2019/5/26.
//

import Foundation

class StructGenerator {
    
    private let structs: [TStruct]
    
    init(structs: [TStruct]) {
        self.structs = structs.sorted(by: { $0.name < $1.name })
    }
    
    func generateThriftStructs(printer p: inout CodePrinter) {
        for s in self.structs {
            self.generateStruct(s: s, printer: &p)
        }
    }
    
    private func generateStruct(s: TStruct, printer p: inout CodePrinter) {
        p.print("public struct RT\(s.name): Codable {\n")
        p.indent()
        s.fields.forEach { field in
            p.print("public let \(field.name): \(field.generateSwiftTypeName())\n")
        }
        self.generateStructInit(values: s.fields, printer: &p)
        p.outdent()
        p.print("}\n")
        p.print("\n")
    }
    
    private func generateStructInit(values: [TField], printer p: inout CodePrinter) {
        p.print("public init(\(values.map({ "\($0.name): \($0.generateSwiftTypeName())" }).joined(separator: ", "))) {\n")
        p.indent()
        values.forEach { v in
            p.print("self.\(v.name) = \(v.name)\n")
        }
        p.outdent()
        p.print("}\n")
    }
}
