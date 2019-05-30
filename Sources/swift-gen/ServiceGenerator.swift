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
        self.service = services.sorted(by: { $0.name < $1.name })
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
        let methods = s.methods.map({ $0.value }).sorted(by: { $0.name < $1.name })
        p.print("public enum \(s.name) {\n")
        p.indent()
        for method in methods {
            if !method.arguments.isEmpty {
                p.print("\n")
            }
            self.generateClientServiceParameterStruct(m: method, printer: &p)
            p.print("\n")
            self.generateClientServiceRequest(sn: s.name, m: method, printer: &p)
        }
        p.outdent()
        p.print("}\n")
    }
    
    private func generateClientServiceParameterStruct(m: TMethod, printer p: inout CodePrinter) {
        guard !m.arguments.isEmpty else { return }
        p.print("public struct \(m.name.firstUppercased()): Codable {\n")
        p.indent()
        for field in m.arguments {
            p.print("public let \(field.name): \(field.generateSwiftTypeName())\n")
        }
        p.outdent()
        p.print("}\n")
    }
    
    private func generateClientServiceRequest(sn: String, m: TMethod, printer p: inout CodePrinter) {
        let returnType: String
        if let rt = m.returnType {
            returnType = rt.generateSwiftTypeName()
        } else {
            returnType = "RTVoid"
        }
        let arguments = m.arguments.map({ "\($0.name): \($0.generateSwiftTypeName())" }).joined(separator: ", ")
        if m.arguments.isEmpty {
            p.print("public static func \(m.name)() throws -> RTRequest<RTVoid, \(returnType)> {\n")
        } else {
            p.print("public static func \(m.name)(\(arguments)) throws -> RTRequest<\(sn).\(m.name.firstUppercased()), \(returnType)> {\n")
        }
        p.indent()
        p.print("return try RTRequest(\n")
        p.indent()
        p.print("method: \"\(sn).\(m.name)\",\n")
        if m.arguments.isEmpty {
            p.print("parameter: RTVoid(),\n")
        } else {
            p.print("parameter: \(sn).\(m.name.firstUppercased())(\(m.arguments.map({ "\($0.name): \($0.name)" }).joined(separator: ", "))),\n")
        }
        p.print("responseType: \(returnType).self\n")
        p.outdent()
        p.print(")\n")
        p.outdent()
        p.print("}\n")
    }
    
    private func generateServerService(s: TService, printer p: inout CodePrinter) {
        p.print("\n")
        self.generateServerServiceProtocol(s: s, printer: &p)
        self.generateServerServiceImplementation(s: s, printer: &p)
    }
    
    private func generateServerServiceProtocol(s: TService, printer p: inout CodePrinter) {
        let methods = s.methods.map({ $0.value }).sorted(by: { $0.name < $1.name })
        p.print("protocol __RT\(s.name)Protocol: class {\n")
        p.indent()
        for method in methods {
            let returnType: String
            if let rt = method.returnType {
                returnType = rt.generateSwiftTypeName()
            } else {
                returnType = "RTVoid"
            }
            if method.arguments.isEmpty {
                p.print("func \(method.name)(withCompletion completion: @escaping (RTResult<\(returnType), RTError>) -> Void)\n")
            } else {
                p.print("func \(method.name)(\(method.arguments.map({ "\($0.name): \($0.generateSwiftTypeName())" }).joined(separator: ", ")), completion: @escaping (RTResult<\(returnType), RTError>) -> Void)\n")
            }
        }
        p.outdent()
        p.print("}\n")
    }
    
    private func generateServerServiceImplementation(s: TService, printer p: inout CodePrinter) {
        let methods = s.methods.map({ $0.value }).sorted(by: { $0.name < $1.name })
        p.print("\n")
        p.print("@objc(RT\(s.name))\n")
        p.print("class RT\(s.name): NSObject, __RT\(s.name)Protocol {\n")
        p.indent()
        for method in methods {
            p.print("@objc private func __\(method.name)(parameters: Data, completion: @escaping (Data) -> Void) {\n")
            p.indent()
            if !method.arguments.isEmpty {
                p.print("let req: \(s.name).\(method.name.firstUppercased())\n")
                p.print("do {\n")
                p.indent()
                p.print("req = try \(s.name).\(method.name.firstUppercased()).__rt_throws_from(data: parameters)\n")
                p.outdent()
                p.print("} catch {\n")
                p.indent()
                p.print("completion(RTError(code: .encodeError, errorDescription: error.localizedDescription).__rt_toData())\n")
                p.print("return\n")
                p.outdent()
                p.print("}\n")
            }
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
