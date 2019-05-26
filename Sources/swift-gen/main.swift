import Foundation

guard
    let json = CommandLine.arguments.dropFirst().first,
    let data = json.data(using: .utf8) else {
        exit(1)
}

do {
    let thrifts = try JSONDecoder().decode(TThrifts.self, from: data)
    
    let dirURL = URL(fileURLWithPath: thrifts.output)
    
    try FileManager.default.createDirectory(at: dirURL)
    
    let name = URL(fileURLWithPath: thrifts.input).deletingPathExtension().lastPathComponent.firstUppercased()
    
    let clientFileURL = dirURL.appendingPathComponent("\(name).client.swift")
    let serverFileURL = dirURL.appendingPathComponent("\(name).server.swift")
    
    guard
        let thrift = thrifts.thrifts[thrifts.input] else {
            exit(1)
    }
    
    var client = CodePrinter()
    var server = CodePrinter()
    
    let generator = FileGenerator(thrift: thrift)
    
    generator.generateThriftClientFile(printer: &client)
    generator.generateThriftServerFile(printer: &server)
    
    try client.content.write(to: clientFileURL, atomically: true, encoding: .utf8)
    try server.content.write(to: serverFileURL, atomically: true, encoding: .utf8)
    
} catch {
    print(error)
}

