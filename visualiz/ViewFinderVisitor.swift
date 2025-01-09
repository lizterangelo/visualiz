import SwiftSyntax

/// A SyntaxVisitor that locates SwiftUI view structs.
final class ViewFinderVisitor: SyntaxVisitor {
    var foundViews: [String] = []
    
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        // Check if the struct inherits from "View"
        if let inheritance = node.inheritanceClause?.inheritedTypeCollection {
            let isSwiftUIView = inheritance.contains { inherited in
                inherited.typeName
                    .description
                    .trimmingCharacters(in: .whitespacesAndNewlines) == "View"
            }
            if isSwiftUIView {
                foundViews.append(node.identifier.text)
            }
        }
        
        // Continue visiting child nodes
        return .visitChildren
    }
}
