import SwiftUI
import WebKit

struct CytoscapeWebView: NSViewRepresentable {
    @Binding var elementsJSON: String   // The Cytoscape elements array as JSON
    
    func makeCoordinator() -> Coordinator {
        Coordinator(elementsJSON: $elementsJSON)
    }
    
    func makeNSView(context: Context) -> WKWebView {
        // Create a config so we can add user scripts or message handlers
        let contentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        
        // Load the base HTML
        webView.loadHTMLString(context.coordinator.baseHTML, baseURL: nil)

        
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        let js = "window.updateCytoscapeGraph(\(elementsJSON));"
        nsView.evaluateJavaScript(js, completionHandler: nil)
    }

    
    class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var elementsJSON: String
        
        // A base HTML that loads Cytoscape and defines a global function updateCytoscapeGraph(...)
        let baseHTML: String
        
        init(elementsJSON: Binding<String>) {
            self._elementsJSON = elementsJSON
            // A minimal HTML snippet:
            self.baseHTML = """
            <!DOCTYPE html>
            <html>
              <head>
                <meta charset="utf-8" />
                <title>Cytoscape SwiftUI Integration</title>
                <script src="https://unpkg.com/cytoscape/dist/cytoscape.min.js"></script>
                <style>
                  html, body { margin: 0; padding: 0; height: 100%; }
                  #cy { width: 100%; height: 100%; }
                </style>
              </head>
              <body>
                <div id="cy" style="width: 600px; height: 400px; border: 1px solid red;"></div>
                <script>
                  var cy = null;
                  
                  // Called once the page is loaded
                  document.addEventListener("DOMContentLoaded", function(){
                    cy = cytoscape({
                      container: document.getElementById('cy'),
                      elements: [],  // Start empty
                      style: [
                        {
                          selector: 'node',
                          style: {
                            'background-color': '#666',
                            'label': 'data(id)',
                            'text-valign': 'center',
                            'color': '#fff'
                          }
                        },
                        {
                          selector: 'edge',
                          style: {
                            'width': 3,
                            'line-color': '#ccc',
                            'target-arrow-shape': 'triangle',
                            'target-arrow-color': '#ccc',
                            'curve-style': 'bezier'
                          }
                        }
                      ],
                      layout: { name: 'breadthfirst' }
                    });
                  });
                  
                  // A function to update the graph
                  window.updateCytoscapeGraph = function(newElements) {
                    if(!cy) return;
                    // Remove all old elements
                    cy.elements().remove();
                    
                    // Parse the newElements JSON
                    var parsed = [];
                    try {
                      parsed = JSON.parse(newElements);
                    } catch(e) {
                      console.error("Failed to parse JSON:", e);
                      return null;
                    }
                    
                    cy.add(parsed);
                    cy.layout({ name: 'breadthfirst' }).run();
                    return null;
                  };
                </script>
              </body>
            </html>
            """
            super.init()
        }
        
        // WKNavigationDelegate if needed
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Cytoscape base HTML loaded!")
            // Immediately update with the initial data
            let js = "window.updateCytoscapeGraph(\(elementsJSON));"
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }
}
