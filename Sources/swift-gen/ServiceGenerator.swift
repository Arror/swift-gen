//
//  ServiceGenerator.swift
//  swift-gen
//
//  Created by Arror on 2019/5/26.
//

import Foundation

class ServiceGenerator {
    
    private let service: [TService]
    
    init(services: [TService]) {
        self.service = services
    }
    
    func generateThriftClientServices(printer p: inout CodePrinter) {
        for s in self.service {
            self.generateClientService(s: s, printer: &p)
        }
    }
    
    func generateThriftServerServices(printer p: inout CodePrinter) {
        for s in self.service {
            self.generateServerService(s: s, printer: &p)
        }
    }
    
    private func generateClientService(s: TService, printer p: inout CodePrinter) {
        let methods = s.methods.map { $0.value }
        p.print("\n")
        p.print("public enum \(s.name) {\n")
        p.indent()
        for method in methods {
            guard
                let rt = method.returnType, !method.arguments.isEmpty else {
                    fatalError("Invalid service definition.")
            }
            p.print("\n")
            p.print("public struct \(method.name.firstUppercased()): Codable {\n")
            p.print("\n")
            p.indent()
            for field in method.arguments {
                p.print("public let \(field.name): \(field.generateSwiftTypeName())\n")
            }
            p.outdent()
            p.print("}\n")
            
            p.print("\n")
            let arguments = method.arguments.map({ "\($0.name): \($0.generateSwiftTypeName())" }).joined(separator: ", ")
            p.print("public static func \(method.name)(\(arguments)) throws -> RTRequest<\(s.name).\(method.name.firstUppercased()), \(rt.generateSwiftTypeName())> {\n")
            p.indent()
            p.print("return try RTRequest(\n")
            p.indent()
            p.print("method: \"\(s.name).\(method.name)\",\n")
            p.print("parameter: \(s.name).\(method.name.firstUppercased())(\(method.arguments.map({ "\($0.name): \($0.name)" }).joined(separator: ", "))),\n")
            p.print("responseType: \(rt.generateSwiftTypeName()).self\n")
            p.outdent()
            p.print(")\n")
            p.outdent()
            p.print("}\n")
        }
        p.outdent()
        p.print("}\n")
    }
    
    private func generateServerService(s: TService, printer p: inout CodePrinter) {
        let methods = s.methods.map { $0.value }
        p.print("\n")
        p.print("protocol __RT\(s.name)Protocol: class {\n")
        p.indent()
        for method in methods {
            guard
                let rt = method.returnType, !method.arguments.isEmpty else {
                    fatalError("Invalid service definition.")
            }
            p.print("func \(method.name)(\(method.arguments.map({ "\($0.name): \($0.generateSwiftTypeName())" }).joined(separator: ", ")), completion: @escaping (RTResult<\(rt.generateSwiftTypeName()), RTError>) -> Void)\n")
        }
        p.outdent()
        p.print("}\n")
        
        p.print("\n")
        p.print("@objc(RT\(s.name))\n")
        p.print("class RT\(s.name): NSObject, __RT\(s.name)Protocol {\n")
        p.indent()
        for method in methods {
            p.print("@objc private func __\(method.name)(parameters: Data, completion: @escaping (Data) -> Void) {\n")
            p.indent()
            p.print("let req = \(s.name).\(method.name.firstUppercased()).__rt_from(data: parameters)\n")
            p.print("self.\(method.name)(\(method.arguments.map({ "\($0.name): req.\($0.name)" }).joined(separator: ", "))) { result in\n")
            p.indent()
            p.print("completion(result.__rt_toData())\n")
            p.outdent()
            p.print("}\n")
            p.outdent()
            p.print("}\n")
        }
        p.outdent()
        p.print("}\n")
    }
}
