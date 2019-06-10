//
//  CodePrinter.swift
//  swift-gen
//
//  Created by Arror on 2019/5/26.
//

import Foundation

public struct CodePrinter {
    
    private static let initialBufferSize = 65536
    
    public var content: String {
        return String(self.contentScalars)
    }
    
    public var isEmpty: Bool { return self.content.isEmpty }
    
    private var contentScalars = String.UnicodeScalarView()
    
    private let singleIndent: String.UnicodeScalarView
    
    private var indentation = String.UnicodeScalarView()
    
    private var atLineStart = true
    
    public init(indent: String.UnicodeScalarView = "    ".unicodeScalars) {
        self.contentScalars.reserveCapacity(CodePrinter.initialBufferSize)
        self.singleIndent = indent
    }
    
    public mutating func print(_ text: String...) {
        for t in text {
            for scalar in t.unicodeScalars {
                if self.atLineStart && scalar != "\n" {
                    self.contentScalars.append(contentsOf: self.indentation)
                }
                self.contentScalars.append(scalar)
                self.atLineStart = (scalar == "\n")
            }
        }
    }
    
    public mutating func indent() {
        self.indentation.append(contentsOf: self.singleIndent)
    }
    
    public mutating func outdent() {
        let indentCount = self.singleIndent.count
        precondition(self.indentation.count >= indentCount, "Cannot outdent past the left margin")
        self.indentation.removeLast(indentCount)
    }
}
