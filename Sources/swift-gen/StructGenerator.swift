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
    
    func generateThriftStructs(scope: Scope, printer p: inout CodePrinter) {
        for s in self.structs {
            self.generateStruct(scope: scope, s: s, printer: &p)
        }
    }
    
    private func generateStruct(scope: Scope,  s: TStruct, printer p: inout CodePrinter) {
        let accessControl: String = (scope == .client) ? "public " : ""
        p.print("\(accessControl)struct \(scope.prefix)\(s.name): Codable {\n")
        p.indent()
        s.fields.forEach { field in
            p.print("\(accessControl)let \(field.name): \(field.generateSwiftTypeName(scope: scope))\n")
        }
        self.generateStructInit(scope: scope, values: s.fields, printer: &p)
        p.outdent()
        p.print("}\n")
        p.print("\n")
    }
    
    private func generateStructInit(scope: Scope, values: [TField], printer p: inout CodePrinter) {
        let accessControl: String = (scope == .client) ? "public " : ""
        p.print("\(accessControl)init(\(values.map({ "\($0.name): \($0.generateSwiftTypeName(scope: scope))" }).joined(separator: ", "))) {\n")
        p.indent()
        values.forEach { v in
            p.print("self.\(v.name) = \(v.name)\n")
        }
        p.outdent()
        p.print("}\n")
    }
}
