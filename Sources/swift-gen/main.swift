import Foundation

enum Global {
    static fileprivate(set) var clientNamespace: String = ""
    static fileprivate(set) var serverNamespace: String = ""
}

struct GeneratorError: LocalizedError {
    
    let errorDescription: String?
    
    init(_ errorDescription: String) {
        self.errorDescription = errorDescription
    }
}

do {
    guard
        let json = CommandLine.arguments.dropFirst().first,
        let data = json.data(using: .utf8) else {
            throw GeneratorError("Thrift file parse error.")
    }
    
    let thrifts = try JSONDecoder().decode(TThrifts.self, from: data)
    
    guard
        thrifts.version == "3.0" else {
            throw GeneratorError("Version of thrift 2.0 is required.")
    }
    
    Global.clientNamespace = thrifts.clientNamespcae
    Global.serverNamespace = thrifts.serverNamespace
    
    let clientDirURL = URL(fileURLWithPath: thrifts.clientOutput)
    let serverDirURL = URL(fileURLWithPath: thrifts.serverOutput)
    
    try FileManager.default.createDirectory(at: clientDirURL)
    try FileManager.default.createDirectory(at: serverDirURL)
    
    let name = URL(fileURLWithPath: thrifts.input).deletingPathExtension().lastPathComponent.firstUppercased()
    
    let clientFileURL = clientDirURL.appendingPathComponent("\(name).c.swift")
    let serverFileURL = serverDirURL.appendingPathComponent("\(name).s.swift")
    
    guard
        let thrift = thrifts.thrifts[thrifts.input] else {
            throw GeneratorError("Thrift file not found.")
    }
    
    var client = CodePrinter()
    var server = CodePrinter()
    
    let generator = FileGenerator(thrift: thrift)
    
    try generator.generateFile(type: .client, printer: &client)
    try generator.generateFile(type: .server, printer: &server)
    
    try client.content.write(to: clientFileURL, atomically: true, encoding: .utf8)
    try server.content.write(to: serverFileURL, atomically: true, encoding: .utf8)
    
    exit(0)
} catch {
    print(error.localizedDescription)
    exit(0)
}

