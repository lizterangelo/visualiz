import Foundation
import SwiftSyntax       // For AST node types
import SwiftParser       // For Parser.parse(source:)

/// Enumerate all `.swift` files in the given directory (recursively).
func swiftFiles(in directory: URL) -> [URL] {
    var result: [URL] = []
    
    if let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: nil) {
        for element in enumerator {
            guard let fileURL = element as? URL else { continue }
            
            if fileURL.pathExtension.lowercased() == "swift" {
                result.append(fileURL)
            }
        }
    } else {
        print("Enumerator is nil for:", directory.path)
    }
    
    return result
}


/// Parse a single `.swift` file with SwiftSyntax 6, returning a `SourceFileSyntax`.
func parseSwiftFile(at fileURL: URL) throws -> SourceFileSyntax {
    let sourceCode = try String(contentsOf: fileURL, encoding: .utf8)
    // SwiftParser API for SwiftSyntax 6:
    return Parser.parse(source: sourceCode)
}

/// Build a flat list of SwiftUIViewNode for each discovered SwiftUI struct in the directory.
func buildViewNodes(in directory: URL) -> [SwiftUIViewNode] {
    var nodes: [SwiftUIViewNode] = []
    let fileURLs = swiftFiles(in: directory)
    
    for fileURL in fileURLs {
        do {
            // Parse the file into a syntax tree
            let sourceFileSyntax = try parseSwiftFile(at: fileURL)
            
            // Use our visitor to find SwiftUI structs
            let visitor = ViewFinderVisitor(viewMode: .all)
            visitor.walk(sourceFileSyntax)
            
            // For each discovered view, create a SwiftUIViewNode
            for viewName in visitor.foundViews {
                let node = SwiftUIViewNode(name: viewName, filePath: fileURL.path)
                nodes.append(node)
            }
        } catch {
            print("Failed to parse \(fileURL.lastPathComponent): \(error)")
        }
    }
    
    return nodes
}
