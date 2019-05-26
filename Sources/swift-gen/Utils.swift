//
//  Utils.swift
//  swift-gen
//
//  Created by Arror on 2019/5/26.
//

import Foundation

extension TField {
    
    func generateSwiftTypeName() -> String {
        guard
            let type = self.type else {
                fatalError("Invlaid field type.")
        }
        return "\(type.generateSwiftTypeName())\(self.isOptional ? "?" : "")"
    }
}


extension TType {
    
    func generateSwiftTypeName() -> String {
        let reval: String
        switch self.name {
        case "map", "set", "byte", "void":
            fatalError("Unsupport type: \(self.name).")
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
                    fatalError("Unsupport type.")
            }
            reval = "[\(TType(name: vt.name, keyType: .none, valueType: .none).generateSwiftTypeName())]"
        default:
            reval = self.name
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
                
        if self.fileExists(atPath: url.path) {
            try self.removeItem(at: url)
        } else {
            try self.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
