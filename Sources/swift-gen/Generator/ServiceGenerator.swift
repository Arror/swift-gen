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
        p.print("\n")
        p.indent()
        for method in methods {
            let returnType = try method.generateSwiftTypeName(type: .client)
            if method.arguments.isEmpty {
                p.print("case \(method.name)(completion: (Swift.Result<\(returnType), Error>) -> Void)\n")
            } else {
                let arguments = try method.arguments.map({ "\($0.name): \(try $0.generateSwiftTypeName(type: .client))" }).joined(separator: ", ")
                p.print("case \(method.name)(\(arguments), completion: (Swift.Result<\(returnType), Error>) -> Void)\n")
            }
        }
        p.print("\n")
        p.print("public enum Methods: String, CaseIterable {\n")
        p.indent()
        for method in methods {
            p.print("case \(method.name) = \"\(s.name).\(method.name)\"\n")
        }
        p.outdent()
        p.print("}\n")
        p.print("\n")
        p.print("public func invoke(by session: CloverKit.Session = .shared) -> Bool {\n")
        p.indent()
        p.print("switch self {\n")
        for method in methods {
            if method.arguments.isEmpty {
                p.print("case .\(method.name)(let completion):\n")
            } else {
                p.print("case .\(method.name)(\(method.arguments.map({ "let \($0.name)" }).joined(separator: ", ")), let completion):\n")
            }
            p.indent()
            if !method.arguments.isEmpty {
                try self.generateParameterStruct(type: .client, method: method, printer: &p)
            }
            p.print("return session.invoke(\n")
            p.indent()
            p.print("method: Methods.\(method.name).rawValue,\n")
            if method.arguments.isEmpty {
                p.print("parameter: CloverKit.Empty(),\n")
            } else {
                p.print("parameter: Parameter(\(method.arguments.map({ "\($0.name): \($0.name)" }).joined(separator: ", "))),\n")
            }
            p.print("completion: completion\n")
            p.outdent()
            p.print(")\n")
            p.outdent()
        }
        p.print("}\n")
        p.outdent()
        p.print("}\n")
        p.outdent()
        p.print("}\n")
    }
    
    private func generateServerServiceProtocol(service s: TService, printer p: inout CodePrinter) throws {
        let methods = s.methods.map({ $0.value }).sorted(by: { $0.name < $1.name })
        p.print("protocol __CK\(s.name)Protocol: class {\n")
        p.indent()
        for method in methods {
            p.print("\n")
            let returnType = try method.generateSwiftTypeName(type: .server)
            if method.arguments.isEmpty {
                p.print("func \(method.name)(withCompletion completion: @escaping (Swift.Result<\(returnType), Swift.Error>) -> Void) -> Bool\n")
            } else {
                p.print("func \(method.name)(\(try method.arguments.map({ "\($0.name): \(try $0.generateSwiftTypeName(type: .server))" }).joined(separator: ", ")), completion: @escaping (Swift.Result<\(returnType), Swift.Error>) -> Void) -> Bool\n")
            }
        }
        p.outdent()
        p.print("}\n")
        p.print("\n")
    }
    
    private func generateServerServiceImplementation(service s: TService, printer p: inout CodePrinter) throws {
        let methods = s.methods.map({ $0.value }).sorted(by: { $0.name < $1.name })
        p.print("@objc(CK\(s.name))\n")
        p.print("class CK\(s.name): NSObject, __CK\(s.name)Protocol {\n")
        p.indent()
        for method in methods {
            p.print("\n")
            p.print("@objc private func __\(method.name)(handler: CloverKit.Handler) -> Bool {\n")
            p.indent()
            if method.arguments.isEmpty {
                p.print("return self.\(method.name) { result in\n")
                p.indent()
                self.generateServerHandler(printer: &p)
                p.outdent()
                p.print("}\n")
            } else {
                try self.generateParameterStruct(type: .server, method: method, printer: &p)
                p.print("do {\n")
                p.indent()
                p.print("let p = try JSONDecoder().decode(Parameter.self, from: handler.parameter)\n")
                p.print("return self.\(method.name)(\(method.arguments.map({ "\($0.name): p.\($0.name)" }).joined(separator: ", "))) { result in\n")
                p.indent()
                self.generateServerHandler(printer: &p)
                p.outdent()
                p.print("}\n")
                p.outdent()
                p.print("} catch {\n")
                p.indent()
                p.print("handler.completion(.failure(error))\n")
                p.print("return false\n")
                p.outdent()
                p.print("}\n")
            }
            p.outdent()
            p.print("}\n")
        }
        p.outdent()
        p.print("}\n")
    }
    
    private func generateServerHandler(printer p: inout CodePrinter) {
        p.print("handler.completion(result.flatMap {\n")
        p.indent()
        p.print("do {\n")
        p.indent()
        p.print("return .success(try JSONEncoder().encode($0))\n")
        p.outdent()
        p.print("} catch {\n")
        p.indent()
        p.print("return .failure(error)\n")
        p.outdent()
        p.print("}\n")
        p.outdent()
        p.print("})\n")
    }
}
