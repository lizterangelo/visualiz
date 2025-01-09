import Foundation
import SwiftSyntax
import SwiftParser

final class CollectStructsVisitor: SyntaxVisitor {
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        // Check if it inherits from "View"
        if let inheritance = node.inheritanceClause?.inheritedTypeCollection {
            let isSwiftUIView = inheritance.contains { inherited in
                inherited.typeName.description.trimmingCharacters(in: .whitespacesAndNewlines) == "View"
            }
            if isSwiftUIView {
                let structName = node.identifier.text
                // Add to our global dictionary if not present
                if allViewsDict[structName] == nil {
                    let newNode = ViewASTNode(name: structName)
                    allViewsDict[structName] = newNode
                    topLevelNames.insert(structName)
                }
            }
        }
        return .visitChildren
    }
}

final class LinkChildrenVisitor: SyntaxVisitor {
    private var currentStructName: String?
    
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        // Check if this struct inherits from "View"
        if let inheritance = node.inheritanceClause?.inheritedTypeCollection {
            let isSwiftUIView = inheritance.contains { inherited in
                inherited.typeName.description.trimmingCharacters(in: .whitespacesAndNewlines) == "View"
            }
            if isSwiftUIView {
                currentStructName = node.identifier.text
            } else {
                currentStructName = nil
            }
        } else {
            currentStructName = nil
        }
        return .visitChildren
    }
    
    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        // If currentStructName is set, we're inside that struct's body
        guard let parentName = currentStructName else {
            return .visitChildren
        }
        
        // e.g., `ChildView()`
        if let calledExpr = node.calledExpression.as(IdentifierExprSyntax.self) {
            let childName = calledExpr.identifier.text
            // Check if childName is in our dictionary
            if allViewsDict[childName] != nil {
                // Link the child to the parent's .children
                if var parentNode = allViewsDict[parentName],
                   let childNode = allViewsDict[childName] {
                    
                    // Append child
                    parentNode.children.append(childNode)
                    allViewsDict[parentName] = parentNode
                    // Remove from topLevel
                    topLevelNames.remove(childName)
                }
            }
        }
        
        return .visitChildren
    }
}

final class ChildViewFinderVisitor: SyntaxVisitor {
    var childViewNames: [String] = []
    
    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        // e.g., `SomeChildView(...)`
        if let calledExpr = node.calledExpression.as(IdentifierExprSyntax.self) {
            let viewName = calledExpr.identifier.text
            // A naive check: if it starts with a capital letter, assume it's a custom SwiftUI view
            if viewName.first?.isUppercase == true {
                childViewNames.append(viewName)
            }
        }
        return .visitChildren
    }
}

/// Parse a single file into a syntax tree
func parseFile(_ fileURL: URL) throws -> SourceFileSyntax {
    let sourceCode = try String(contentsOf: fileURL)
    return Parser.parse(source: sourceCode)
}

/// The main two-pass function that returns a [ViewASTNode] hierarchy
func twoPassBuildAST(in directory: URL) -> [ViewASTNode] {
    // Clear global dictionaries so repeated calls won't cause duplicates
    allViewsDict.removeAll()
    topLevelNames.removeAll()
    
    // 1) First pass: Collect all views
    let files = swiftFiles(in: directory)
    for fileURL in files {
        do {
            let tree = try parseFile(fileURL)
            let collector = CollectStructsVisitor(viewMode: .all)
            collector.walk(tree)
            
            // After the visitor, we've discovered each `struct <Name>: View`
            // but haven't linked children yet.
            
            // Also, attach filePath for newly discovered nodes if you want
            // for (name, node) in allViewsDict {
            //     if node.filePath == nil { ... }  // Optionally set
            // }
        } catch {
            print("First pass parse error: \(fileURL.lastPathComponent) - \(error)")
        }
    }
    
    // 2) Second pass: link children
    for fileURL in files {
        do {
            let tree = try parseFile(fileURL)
            let linker = LinkChildrenVisitor(viewMode: .all)
            linker.walk(tree)
            
            // Now child calls are matched to actual nodes
        } catch {
            print("Second pass parse error: \(fileURL.lastPathComponent) - \(error)")
        }
    }
    
    // 3) Build final array of root nodes
    var rootNodes: [ViewASTNode] = []
    for name in topLevelNames {
        // Each top-level name should exist in allViewsDict
        if let node = allViewsDict[name] {
            rootNodes.append(node)
        }
    }
    
    // 4) Optionally attach filePath for each node if you like
    // or do it in the visitors. Up to you.
    
    // Return the real hierarchy
    return rootNodes
}
