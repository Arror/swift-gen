import Foundation

guard
    let json = CommandLine.arguments.dropFirst().first,
    let data = json.data(using: .utf8) else {
        exit(1)
}

do {
    let thrifts = try JSONDecoder().decode(TThrifts.self, from: data)
    print(thrifts)
} catch {
    print(error)
}
