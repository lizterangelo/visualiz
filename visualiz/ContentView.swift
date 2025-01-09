import SwiftUI
import AppKit

struct ContentView: View {
    @State private var selectedFolderPath: String = ""
    
    // For enumerating + flat detection
    @State private var swiftFileURLs: [URL] = []
    @State private var discoveredViews: [SwiftUIViewNode] = []
    
    // For AST hierarchy
    @State private var astRoots: [ViewASTNode] = []
    
    // The JSON that CytoscapeWebView needs
    @State private var cytoscapeElementsJSON: String = "[]"

    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                Button("Choose Folder") {
                    let panel = NSOpenPanel()
                    panel.canChooseDirectories = true
                    panel.canChooseFiles = false
                    panel.allowsMultipleSelection = false
                    
                    if panel.runModal() == .OK, let folderURL = panel.url {
                        selectedFolderPath = folderURL.path
                        
                        // 1) Build the AST
                        let roots = twoPassBuildAST(in: folderURL)
                        self.astRoots = roots
                        
                        // 2) Convert to Cytoscape JSON
                        let jsonString = astNodesToCytoscapeElements(roots)
                        cytoscapeElementsJSON = jsonString
                        
                        
                        print("AST Roots:", astRoots)
                        print("Cytoscape JSON:", cytoscapeElementsJSON)

                    }
                }
                
                Text("Selected folder: \(selectedFolderPath)")
                    .foregroundColor(.secondary)
                
                // Show discovered .swift files
                VStack(alignment: .leading) {
                    Text("Found Swift files:")
                        .font(.headline)
                    List(swiftFileURLs, id: \.self) { fileURL in
                        Text(fileURL.lastPathComponent)
                    }
                    .frame(height: 120)
                }
                
                // Show discovered SwiftUI Views (flat)
                VStack(alignment: .leading) {
                    Text("Discovered SwiftUI Views (Flat):")
                        .font(.headline)
                    List(discoveredViews) { node in
                        Text("\(node.name) - \(node.filePath)")
                    }
                    .frame(height: 120)
                }
                
                // Show the AST in a custom tree
                VStack(alignment: .leading, spacing: 8) {
                    Text("AST Hierarchy (TreeView):")
                        .font(.headline)
                    
                    if !astRoots.isEmpty {
                        // Render each root node in a "tree-like" format
                        ForEach(astRoots) { rootNode in
                            TreeView(node: rootNode, indentLevel: 0)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(4)
                        }
                    } else {
                        Text("No SwiftUI views in AST.")
                    }
                }
                VStack(spacing: 16) {
                    // Show the AST in text form (optional)
                    List(astRoots, id: \.id) { node in
                        Text("\(node.name) — children: \(node.children.count)")
                    }
                    .frame(height: 150)
                    
                    // The Cytoscape web view
                    CytoscapeWebView(elementsJSON: $cytoscapeElementsJSON)
                        .frame(minWidth: 600, minHeight: 400)
                }
            }
            .padding()
            .frame(minWidth: 600, minHeight: 600)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
