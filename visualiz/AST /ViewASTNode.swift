import Foundation

/// Represents a SwiftUI view node and its children.
struct ViewASTNode: Identifiable {
    let id = UUID()
    let name: String          // e.g. "MainView"
    var filePath: String?     // e.g. "/path/to/MainView.swift"
    var children: [ViewASTNode] = []
    
    init(name: String, filePath: String? = nil, children: [ViewASTNode] = []) {
        self.name = name
        self.filePath = filePath
        self.children = children
    }
    
    // Optional convenience for OutlineGroup or custom tree
    var childrenIfAny: [ViewASTNode]? {
        children.isEmpty ? nil : children
    }
}

/// A global dictionary that we'll build in two passes:
/// "ViewName" -> ViewASTNode
var allViewsDict: [String : ViewASTNode] = [:]

/// A set of names that are still considered top-level candidates
/// until we discover they're used as a child.
var topLevelNames = Set<String>()
