import SwiftUI

/// A recursive view that displays a ViewASTNode tree with indentation.
struct TreeView: View {
    let node: ViewASTNode
    let indentLevel: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Render this node
            HStack {
                // Indent by adding leading space or a spacer
                Spacer().frame(width: CGFloat(indentLevel * 16))
                
                // Node name
                Text(node.name)
                    .fontWeight(.medium)
                
                // Optionally show file path
                if let path = node.filePath {
                    Text("(\(path))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            
            // Render each child, increasing the indent level
            ForEach(node.childrenIfAny ?? []) { child in
                TreeView(node: child, indentLevel: indentLevel + 1)
            }
        }
    }
}
