import Foundation

/// Convert the hierarchical [ViewASTNode] into a Cytoscape "elements" JSON string.
func astNodesToCytoscapeElements(_ roots: [ViewASTNode]) -> String {
    var nodeSet = Set<String>()    // Keep track of all node IDs we’ve added
    var edges = [String]()         // We'll store edge JSON strings
    var nodes = [String]()         // We'll store node JSON strings
    
    // A helper function to recursively traverse the AST
    func traverse(_ parent: ViewASTNode) {
        // Add parent node if not already added
        if !nodeSet.contains(parent.name) {
            let nodeStr = """
            {"data":{"id":"\(parent.name)"}}
            """
            nodes.append(nodeStr)
            nodeSet.insert(parent.name)
        }
        
        // For each child, add an edge (parent -> child), then traverse the child
        for child in parent.children {
            let edgeStr = """
            {"data":{"source":"\(parent.name)","target":"\(child.name)"}}
            """
            edges.append(edgeStr)
            
            // Recursively add the child
            traverse(child)
        }
    }
    
    // Traverse each root
    for root in roots {
        traverse(root)
    }
    
    // Combine everything into a single array
    // elements = [ nodeObj, nodeObj, ..., edgeObj, edgeObj ... ]
    let elementsArray = nodes + edges
    let joined = elementsArray.joined(separator: ",")
    let jsonString = "[\(joined)]"
    return jsonString
}
