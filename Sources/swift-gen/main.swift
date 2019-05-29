import Foundation

guard
    let json = CommandLine.arguments.dropFirst().first,
    let data = json.data(using: .utf8) else {
        print("Thrift file data parse error.")
        exit(0)
}

do {
    let thrifts = try JSONDecoder().decode(TThrifts.self, from: data)
    
    guard
        thrifts.version == "1.1" else {
            print("Version of thrift 1.1 is required.")
            exit(0)
    }
    
    let dirURL = URL(fileURLWithPath: thrifts.output)
    
    try FileManager.default.createDirectory(at: dirURL)
    
    let name = URL(fileURLWithPath: thrifts.input).deletingPathExtension().lastPathComponent.firstUppercased()
    
    let clientFileURL = dirURL.appendingPathComponent("\(name).client.swift")
    let serverFileURL = dirURL.appendingPathComponent("\(name).server.swift")
    
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

