//
//  Utils.swift
//  swift-gen
//
//  Created by Arror on 2019/5/26.
//

import Foundation

enum Scope {
    
    case client
    case server
    
    var prefix: String {
        switch self {
        case .client:
            return "RT"
        case .server:
            return "RTServer"
        }
    }
}

extension TField {
    
    func generateSwiftTypeName(scope: Scope) -> String {
        guard
            let type = self.type else {
                fatalError("Invlaid field type.")
        }
        return "\(type.generateSwiftTypeName(scope: scope))\(self.isOptional ? "?" : "")"
    }
}


extension TType {
    
    func generateSwiftTypeName(scope: Scope) -> String {
        let reval: String
        switch self.name {
        case "map", "set", "byte":
            print("Unsupport type: \(self.name).")
            exit(0)
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
                let vt = self.valueType, !vt.name.isEmpty, vt.name != "list" else {
                    print("Unsupport type: \(self.name).")
                    exit(0)
            }
            reval = "[\(TType(name: vt.name, valueType: .none).generateSwiftTypeName(scope: scope))]"
        default:
            reval = "\(scope.prefix)\(self.name)"
        }
        return reval
    }
}

extension String {
    
    func firstUppercased() -> String {
        if let first = self.uppercased().first {
            return String([first]).appending(String(self.dropFirst()))
        } else {
            return self
        } 
    }
}

extension FileManager {
    
    func createDirectory(at url: URL) throws {
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
