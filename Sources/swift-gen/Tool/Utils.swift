//
//  Utils.swift
//  swift-gen
//
//  Created by Arror on 2019/5/26.
//

import Foundation

public enum FileType {
    
    case client
    case server
    
    public var prefix: String {
        switch self {
        case .client:
            return Global.clientNamespace
        case .server:
            return Global.serverNamespace
        }
    }
}

extension TMethod {
    
    public func generateSwiftTypeName(type: FileType) throws -> String {
        if let t = self.returnType {
            return try t.generateSwiftTypeName(type: type)
        } else {
            return "CloverKit.Empty"
        }
    }
}

extension TField {
    
    public func generateSwiftTypeName(type: FileType) throws -> String {
        if let t = self.type {
            return "\(try t.generateSwiftTypeName(type: type))\(self.isOptional ? "?" : "")"
        } else {
            throw GeneratorError("Invlaid filed type, filed name: \(self.name)")
        }
    }
}


extension TType {
    
    private static let unsupportedThriftTypes: Set<String> = ["map", "set", "byte"]
    private static let unsupportedThriftElementTypes: Set<String> = ["map", "set", "byte", "list"]
    
    public func generateSwiftTypeName(type: FileType) throws -> String {
        guard
            !TType.unsupportedThriftTypes.contains(self.name) else {
                throw GeneratorError("Unsupport type: \(self.name).")
        }
        let reval: String
        switch self.name {
        case "i16":
            reval = "Int16"
        case "i32":
            reval = "Int"
        case "i64":
            reval = "Int64"
        case "double":
            reval = "Double"
        case "bool":
            reval = "Bool"
        case "string":
            reval = "String"
        case "list":
            guard
                let valueType = self.valueType, TType.unsupportedThriftElementTypes.contains(valueType.name) else {
                    throw GeneratorError("Unsupport element type: \(self.name).")
            }
            reval = "[\(try TType(name: valueType.name, valueType: .none).generateSwiftTypeName(type: type))]"
        default:
            reval = "\(type.prefix)\(self.name)"
        }
        return reval
    }
}

extension String {
    
    public func firstUppercased() -> String {
        guard
            let first = self.uppercased().first else {
                return self
        }
        return String([first]).appending(String(self.dropFirst()))
    }
}

extension FileManager {
    
    public func createDirectory(at url: URL) throws {
        var isDirectory: ObjCBool = false
        if self.fileExists(atPath: url.path, isDirectory: &isDirectory) {
            if !isDirectory.boolValue {
                let underlyingError = NSError(domain: POSIXError.errorDomain, code: Int(POSIXErrorCode.ENOTDIR.rawValue))
                throw CocoaError.error(.fileWriteUnknown, userInfo: [NSUnderlyingErrorKey: underlyingError], url: url)
            }
        } else {
            try self.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
