import Foundation

guard
    let json = CommandLine.arguments.dropFirst().first,
    let data = json.data(using: .utf8) else {
        print("Thrift file data parse error.")
        exit(0)
}

enum Global {
    static var clientNamespace: String = ""
    static var serverNamespace: String = ""
}

do {
    let thrifts = try JSONDecoder().decode(TThrifts.self, from: data)
    
    guard
        thrifts.version == "2.0" else {
            print("Version of thrift 2.0 is required.")
            exit(0)
    }
    
    Global.clientNamespace = thrifts.clientNamespcae
    Global.serverNamespace = thrifts.serverNamespace
    
    let dirURL = URL(fileURLWithPath: thrifts.output)
    
    try FileManager.default.createDirectory(at: dirURL)
    
    let name = URL(fileURLWithPath: thrifts.input).deletingPathExtension().lastPathComponent.firstUppercased()
    
    let clientFileURL = dirURL.appendingPathComponent("\(name).c.swift")
    let serverFileURL = dirURL.appendingPathComponent("\(name).s.swift")
    
    guard
        let thrift = thrifts.thrifts[thrifts.input] else {
            print("Thrift file not found.")
            exit(0)
    }
    
    var client = CodePrinter()
    var server = CodePrinter()
    
    let generator = FileGenerator(thrift: thrift)
    
    generator.generateThriftClientFile(printer: &client)
    generator.generateThriftServerFile(printer: &server)
    
    try client.content.write(to: clientFileURL, atomically: true, encoding: .utf8)
    try server.content.write(to: serverFileURL, atomically: true, encoding: .utf8)
    
    exit(0)
} catch {
    print(error)
    exit(0)
}

