import SwiftUI

// MARK: - Root → Middle → Child

/// The top-level view that references MiddleView in its body.
struct RootView: View {
    var body: some View {
        // In a real app, you might have NavigationView or something else here.
        MiddleView()
    }
}

/// A "middle" view that references ChildView.
struct MiddleView: View {
    var body: some View {
        ChildView()
    }
}

/// The final child in this chain, just displays some text.
struct ChildView: View {
    var body: some View {
        Text("Hello from ChildView!")
    }
}

// MARK: - Sibling Hierarchy

/// A sibling-like view that references two AnotherChildView instances in a VStack.
struct SiblingView: View {
    var body: some View {
        VStack {
            AnotherChildView()
            AnotherChildView()
        }
    }
}

/// Another child view that displays different text.
struct AnotherChildView: View {
    var body: some View {
        Text("Hello from AnotherChildView!")
    }
}

// MARK: - A Second Root-like View

/// Another "root"-style view that might reference both RootView and SiblingView in one body.
struct MasterParentView: View {
    var body: some View {
        VStack {
            RootView()
            SiblingView()
        }
    }
}

/*
How the hierarchy looks:

- MasterParentView
  - RootView
    - MiddleView
      - ChildView
  - SiblingView
    - AnotherChildView
    - AnotherChildView

- RootView
  - MiddleView
    - ChildView

- SiblingView
  - AnotherChildView
  - AnotherChildView

(Each struct is top-level in this file, so your parser will see multiple "struct ... : View" definitions.)
*/
