import Foundation

/// Represents a discovered SwiftUI view node.
struct SwiftUIViewNode: Identifiable {
    let id = UUID()
    let name: String       // e.g., "ContentView"
    let filePath: String   // Path to the .swift file
    var children: [SwiftUIViewNode] = []
}
