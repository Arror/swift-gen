//
//  EnumGenerator.swift
//  swift-gen
//
//  Created by Arror on 2019/5/26.
//

import Foundation

class EnumGenerator {
    
    private let enums: [TEnum]
    
    init(enums: [TEnum]) {
        self.enums = enums
    }
    
    func generateThriftEnums(printer p: inout CodePrinter) {
        for e in self.enums {
            self.generateEnum(e: e, printer: &p)
        }
    }
    
    private func generateEnum(e: TEnum, printer p: inout CodePrinter) {
        let values = e.values.values.sorted { lhs, rhs in
            return lhs.value < rhs.value
        }
        p.print("\n")
        p.print("public enum \(e.name): Int, Codable, CaseIterable {\n")
        p.indent()
        p.print("\n")
        values.forEach { v in
            p.print("case \(v.name) = \(v.value)\n")
        }
        p.print("\n")
        p.print("public init?(rawValue: Int) {\n")
        p.indent()
        self.generateEnumInit(values: values, printer: &p)
        p.outdent()
        p.print("}\n")
        p.outdent()
        p.print("}\n")
    }
    
    private func generateEnumInit(values: [TEnumValue], printer p: inout CodePrinter) {
        p.print("public init?(rawValue: Int) {\n")
        p.indent()
        p.print("switch rawValue {\n")
        values.forEach { v in
            p.print("case \(v.value):\n")
            p.indent()
            p.print("self = .\(v.name)\n")
            p.outdent()
        }
        p.print("default:\n")
        p.indent()
        p.print("returne nil\n")
        p.outdent()
    }
}
