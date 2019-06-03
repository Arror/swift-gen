//
//  StructGenerator.swift
//  swift-gen
//
//  Created by Arror on 2019/5/26.
//

import Foundation

final class StructGenerator {
    
    private let structs: [TStruct]
    
    init(structs: [TStruct]) {
        self.structs = structs.sorted(by: { $0.name < $1.name })
    }
    
    func generateThriftStructs(type: FileType, printer p: inout CodePrinter) {
        for s in self.structs {
            self.generateStruct(type: type, s: s, printer: &p)
        }
    }
    
    private func generateStruct(type: FileType,  s: TStruct, printer p: inout CodePrinter) {
        let control: String = (type == .client) ? "public " : ""
        p.print("\(control)struct \(type.prefix)\(s.name): Codable {\n")
        p.indent()
        s.fields.forEach { field in
            p.print("\(control)let \(field.name): \(field.generateSwiftTypeName(type: type))\n")
        }
        if type == .client {
            self.generateStructInit(type: type, values: s.fields, printer: &p)
        }
        p.outdent()
        p.print("}\n")
        p.print("\n")
    }
    
    private func generateStructInit(type: FileType, values: [TField], printer p: inout CodePrinter) {
        p.print("public init(\(values.map({ "\($0.name): \($0.generateSwiftTypeName(type: type))" }).joined(separator: ", "))) {\n")
        p.indent()
        values.forEach { v in
            p.print("self.\(v.name) = \(v.name)\n")
        }
        p.outdent()
        p.print("}\n")
    }
}
