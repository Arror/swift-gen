//
//  ServiceGenerator.swift
//  swift-gen
//
//  Created by Arror on 2019/5/26.
//

import Foundation

public final class ServiceGenerator {
    
    private let services: [TService]
    
    public init(services: [TService]) {
        self.services = services.sorted(by: { $0.name < $1.name })
    }
    
    public func generateThriftService(type: FileType, printer p: inout CodePrinter) throws {
        for s in self.services {
            switch type {
            case .client:
                try self.generateClientService(service: s, printer: &p)
            case .server:
                try self.generateServerServiceProtocol(service: s, printer: &p)
                try self.generateServerServiceImplementation(service: s, printer: &p)
            }
        }
    }
    
    private func generateParameterStruct(type: FileType, method m: TMethod, printer p: inout CodePrinter) throws {
        guard !m.arguments.isEmpty else { return }
        p.print("struct Parameter: Codable {\n")
        p.indent()
        for field in m.arguments {
            p.print("let \(field.name): \(try field.generateSwiftTypeName(type: type))\n")
        }
        p.outdent()
        p.print("}\n")
    }
    
    private func generateClientService(service s: TService, printer p: inout CodePrinter) throws {
        let methods = s.methods.map({ $0.value }).sorted(by: { $0.name < $1.name })
        p.print("public enum \(s.name) {\n")
        p.indent()
        for method in methods {
            p.print("\n")
            let returnType = try method.generateSwiftTypeName(type: .client)
            let arguments = try method.arguments.map({ "\($0.name): \(try $0.generateSwiftTypeName(type: .client))" }).joined(separator: ", ")
            if method.arguments.isEmpty {
                p.print("public static func \(method.name)() throws -> RTRequest<\(returnType)> {\n")
            } else {
                p.print("public static func \(method.name)(\(arguments)) throws -> RTRequest<\(returnType)> {\n")
                p.indent()
                try self.generateParameterStruct(type: .client, method: method, printer: &p)
                p.outdent()
            }
            p.indent()
            p.print("return try RTRequest(\n")
            p.indent()
            p.print("method: \"\(s.name).\(method.name)\",\n")
            if method.arguments.isEmpty {
                p.print("parameter: RTVoid(),\n")
            } else {
                p.print("parameter: Parameter(\(method.arguments.map({ "\($0.name): \($0.name)" }).joined(separator: ", "))),\n")
            }
            p.print("responseType: \(returnType).self\n")
            p.outdent()
            p.print(")\n")
            p.outdent()
            p.print("}\n")
        }
        p.outdent()
        p.print("}\n")
    }
    
    private func generateServerServiceProtocol(service s: TService, printer p: inout CodePrinter) throws {
        let methods = s.methods.map({ $0.value }).sorted(by: { $0.name < $1.name })
        p.print("protocol __RT\(s.name)Protocol: class {\n")
        p.indent()
        for method in methods {
            p.print("\n")
            let returnType = try method.generateSwiftTypeName(type: .server)
            if method.arguments.isEmpty {
                p.print("func \(method.name)(withCompletion completion: @escaping (RTResult<\(returnType), RTError>) -> Void)\n")
            } else {
                p.print("func \(method.name)(\(try method.arguments.map({ "\($0.name): \(try $0.generateSwiftTypeName(type: .server))" }).joined(separator: ", ")), completion: @escaping (RTResult<\(returnType), RTError>) -> Void)\n")
            }
        }
        p.outdent()
        p.print("}\n")
        p.print("\n")
    }
    
    private func generateServerServiceImplementation(service s: TService, printer p: inout CodePrinter) throws {
        let methods = s.methods.map({ $0.value }).sorted(by: { $0.name < $1.name })
        p.print("@objc(RT\(s.name))\n")
        p.print("class RT\(s.name): NSObject, __RT\(s.name)Protocol {\n")
        p.indent()
        for method in methods {
            p.print("\n")
            p.print("@objc private func __\(method.name)(parameter: Data, completion: @escaping (Data) -> Void) {\n")
            p.indent()
            if !method.arguments.isEmpty {
                try self.generateParameterStruct(type: .server, method: method, printer: &p)
                p.print("let p: Parameter\n")
                p.print("do {\n")
                p.indent()
                p.print("p = try JSONDecoder().decode(Parameter.self, from: parameter)\n")
                p.outdent()
                p.print("} catch {\n")
                p.indent()
                p.print("completion(RTResult<RTVoid, RTError>.failure(RTError(code: .decodeError, errorDescription: error.localizedDescription)).data)\n")
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
