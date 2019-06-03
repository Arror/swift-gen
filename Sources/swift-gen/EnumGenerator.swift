//
//  EnumGenerator.swift
//  swift-gen
//
//  Created by Arror on 2019/5/26.
//

import Foundation

final class EnumGenerator {
    
    private let enums: [TEnum]
    
    init(enums: [TEnum]) {
        self.enums = enums.sorted(by: { $0.name < $1.name })
    }
    
    func generateThriftEnums(type: FileType, printer p: inout CodePrinter) {
        for e in self.enums {
            self.generateEnum(type: type, e: e, printer: &p)
        }
    }
    
    private func generateEnum(type: FileType, e: TEnum, printer p: inout CodePrinter) {
        let values = e.values.values.sorted { lhs, rhs in
            return lhs.value < rhs.value
        }
        let control: String = (type == .client) ? "public " : ""
        p.print("\(control)enum \(type.prefix)\(e.name): Int, Codable, CaseIterable {\n")
        p.indent()
        values.forEach { v in
            p.print("case \(v.name) = \(v.value)\n")
        }
        if type == .client {
            self.generateEnumInit(values: values, printer: &p)
        }
        p.outdent()
        p.print("}\n")
        p.print("\n")
    }
    
    private func generateEnumInit(values: [TEnumValue], printer p: inout CodePrinter) {
        p.print("public init?(rawValue: Int) {\n")
        p.indent()
        p.print("switch rawValue {\n")
        for value in values {
            p.print("case \(value.value):\n")
            p.indent()
            p.print("self = .\(value.name)\n")
            p.outdent()
        }
        p.print("default:\n")
        p.indent()
        p.print("return nil\n")
        p.outdent()
        p.print("}\n")
        p.outdent()
        p.print("}\n")
    }
}
