//
//  StructGenerator.swift
//  swift-gen
//
//  Created by Arror on 2019/5/26.
//

import Foundation

public final class StructGenerator {
    
    private let structs: [TStruct]
    
    public init(structs: [TStruct]) {
        self.structs = structs.sorted(by: { $0.name < $1.name })
    }
    
    public func generateThriftStructs(type: FileType, printer p: inout CodePrinter) throws {
        for s in self.structs {
            try self.generateStruct(type: type, struct: s, printer: &p)
        }
    }
    
    private func generateStruct(type: FileType, struct s: TStruct, printer p: inout CodePrinter) throws {
        let control: String = (type == .client) ? "public " : ""
        p.print("\(control)struct \(type.prefix)\(s.name): Codable {\n")
        p.indent()
        for field in s.fields {
            p.print("\(control)let \(field.name): \(try field.generateSwiftTypeName(type: type))\n")
        }
        switch type {
        case .client:
            try self.generateStructInit(type: type, fields: s.fields, printer: &p)
        case .server:
            break
        }
        p.outdent()
        p.print("}\n")
        p.print("\n")
    }
    
    private func generateStructInit(type: FileType, fields: [TField], printer p: inout CodePrinter) throws {
        p.print("public init(\(try fields.map({ "\($0.name): \(try $0.generateSwiftTypeName(type: type))" }).joined(separator: ", "))) {\n")
        p.indent()
        fields.forEach { v in
            p.print("self.\(v.name) = \(v.name)\n")
        }
        p.outdent()
        p.print("}\n")
    }
}
