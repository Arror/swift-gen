import Foundation

enum Global {
    static fileprivate(set) var clientNamespace: String = ""
    static fileprivate(set) var serverNamespace: String = ""
}

struct GeneratorError: LocalizedError {
    
    let errorDescription: String?
    
    init(errorDescription: String) {
        self.errorDescription = errorDescription
    }
}

do {
    guard
        let json = CommandLine.arguments.dropFirst().first,
        let data = json.data(using: .utf8) else {
            throw GeneratorError(errorDescription: "Thrift file parse error.")
    }
    
    let thrifts = try JSONDecoder().decode(TThrifts.self, from: data)
    
    guard
        thrifts.version == "4.0" else {
            throw GeneratorError(errorDescription: "Version of thrift 4.0 is required.")
    }
    guard
        let thrift = thrifts.thrifts[thrifts.input] else {
            throw GeneratorError(errorDescription: "Thrift file not found.")
    }
    
    Global.clientNamespace = thrifts.clientNamespcae
    Global.serverNamespace = thrifts.serverNamespace
    
    let generator = FileGenerator(thrift: thrift)
    
    let name = URL(fileURLWithPath: thrifts.input).deletingPathExtension().lastPathComponent.firstUppercased()
    
    if !thrifts.clientOutput.isEmpty {
        let clientDirURL = URL(fileURLWithPath: thrifts.clientOutput)
        try FileManager.default.createDirectory(at: clientDirURL)
        let clientFileURL = clientDirURL.appendingPathComponent("\(name).c.swift")
        var client = CodePrinter()
        try generator.generateFile(type: .client, printer: &client)
        try client.content.write(to: clientFileURL, atomically: true, encoding: .utf8)
    }
    
    if !thrifts.serverOutput.isEmpty {
        let serverDirURL = URL(fileURLWithPath: thrifts.serverOutput)
        try FileManager.default.createDirectory(at: serverDirURL)
        let serverFileURL = serverDirURL.appendingPathComponent("\(name).s.swift")
        var server = CodePrinter()
        try generator.generateFile(type: .server, printer: &server)
        try server.content.write(to: serverFileURL, atomically: true, encoding: .utf8)
    }
    
    exit(0)
} catch {
    print(error.localizedDescription)
    exit(0)
}

