//
//  ServiceGenerator.swift
//  swift-gen
//
//  Created by Arror on 2019/5/26.
//

import Foundation

public final class ServiceGenerator {
    
    private let service: [TService]
    
    public init(services: [TService]) {
        self.service = services.sorted(by: { $0.name < $1.name })
    }
    
    public func generateThriftService(type: FileType, printer p: inout CodePrinter) {
        switch type {
        case .client:
            self.generateThriftClientServices(printer: &p)
        case .server:
            self.generateThriftServerServices(printer: &p)
        }
    }
    
    private func generateThriftClientServices(printer p: inout CodePrinter) {
        for s in self.service {
            self.generateClientService(s: s, printer: &p)
        }
    }
    
    private func generateThriftServerServices(printer p: inout CodePrinter) {
        for s in self.service {
            self.generateServerService(s: s, printer: &p)
        }
    }
    
    private func generateClientService(s: TService, printer p: inout CodePrinter) {
        let methods = s.methods.map({ $0.value }).sorted(by: { $0.name < $1.name })
        p.print("public enum \(s.name) {\n")
        p.indent()
        for method in methods {
            p.print("\n")
            self.generateClientServiceRequest(sn: s.name, m: method, printer: &p)
        }
        p.outdent()
        p.print("}\n")
    }
    
    private func generateParameterStruct(type: FileType, m: TMethod, printer p: inout CodePrinter) {
        guard !m.arguments.isEmpty else { return }
        p.print("struct Parameter: Codable {\n")
        p.indent()
        for field in m.arguments {
            p.print("let \(field.name): \(field.generateSwiftTypeName(type: type))\n")
        }
        p.outdent()
        p.print("}\n")
    }
    
    private func generateClientServiceRequest(sn: String, m: TMethod, printer p: inout CodePrinter) {
        let returnType: String
        if let rt = m.returnType {
            returnType = rt.generateSwiftTypeName(type: .client)
        } else {
            returnType = "RTVoid"
        }
        let arguments = m.arguments.map({ "\($0.name): \($0.generateSwiftTypeName(type: .client))" }).joined(separator: ", ")
        if m.arguments.isEmpty {
            p.print("public static func \(m.name)() throws -> RTRequest<\(returnType)> {\n")
        } else {
            p.print("public static func \(m.name)(\(arguments)) throws -> RTRequest<\(returnType)> {\n")
            p.indent()
            self.generateParameterStruct(type: .client, m: m, printer: &p)
            p.outdent()
        }
        p.indent()
        p.print("return try RTRequest(\n")
        p.indent()
        p.print("method: \"\(sn).\(m.name)\",\n")
        if m.arguments.isEmpty {
            p.print("parameter: RTVoid(),\n")
        } else {
            p.print("parameter: Parameter(\(m.arguments.map({ "\($0.name): \($0.name)" }).joined(separator: ", "))),\n")
        }
        p.print("responseType: \(returnType).self\n")
        p.outdent()
        p.print(")\n")
        p.outdent()
        p.print("}\n")
    }
    
    private func generateServerService(s: TService, printer p: inout CodePrinter) {
        self.generateServerServiceProtocol(s: s, printer: &p)
        self.generateServerServiceImplementation(s: s, printer: &p)
    }
    
    private func generateServerServiceProtocol(s: TService, printer p: inout CodePrinter) {
        let methods = s.methods.map({ $0.value }).sorted(by: { $0.name < $1.name })
        p.print("protocol __RT\(s.name)Protocol: class {\n")
        p.indent()
        for method in methods {
            p.print("\n")
            let returnType: String
            if let rt = method.returnType {
                returnType = rt.generateSwiftTypeName(type: .server)
            } else {
                returnType = "RTVoid"
            }
            if method.arguments.isEmpty {
                p.print("func \(method.name)(withCompletion completion: @escaping (RTResult<\(returnType), RTError>) -> Void)\n")
            } else {
                p.print("func \(method.name)(\(method.arguments.map({ "\($0.name): \($0.generateSwiftTypeName(type: .server))" }).joined(separator: ", ")), completion: @escaping (RTResult<\(returnType), RTError>) -> Void)\n")
            }
        }
        p.outdent()
        p.print("}\n")
        p.print("\n")
    }
    
    private func generateServerServiceImplementation(s: TService, printer p: inout CodePrinter) {
        let methods = s.methods.map({ $0.value }).sorted(by: { $0.name < $1.name })
        p.print("@objc(RT\(s.name))\n")
        p.print("class RT\(s.name): NSObject, __RT\(s.name)Protocol {\n")
        p.indent()
        for method in methods {
            p.print("\n")
            p.print("@objc private func __\(method.name)(parameter: Data, completion: @escaping (Data) -> Void) {\n")
            p.indent()
            if !method.arguments.isEmpty {
                self.generateParameterStruct(type: .server, m: method, printer: &p)
                p.print("let p: Parameter\n")
                p.print("do {\n")
                p.indent()
                p.print("p = try JSONDecoder().decode(Parameter.self, from: parameter)\n")
                p.outdent()
                p.print("} catch {\n")
                p.indent()
                p.print("completion(RTResult<RTVoid, RTError>.failure(RTError(code: .encodeError, errorDescription: error.localizedDescription)).data)\n")
                p.print("return\n")
                p.outdent()
                p.print("}\n")
            }
            p.print("self.\(method.name)(\(method.arguments.map({ "\($0.name): p.\($0.name)" }).joined(separator: ", "))) { result in\n")
            p.indent()
            p.print("completion(result.data)\n")
            p.outdent()
            p.print("}\n")
            p.outdent()
            p.print("}\n")
        }
        p.outdent()
        p.print("}\n")
    }
}
