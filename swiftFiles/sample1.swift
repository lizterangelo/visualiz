import SwiftUI

// MARK: - Master Parent
// A top-level parent that references several distinct branches:
// 1) RootView (unconditional)
// 2) AnotherRoot (conditional)
// 3) TertiaryRoot (random selection)
struct MasterParentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("MasterParentView")
                .font(.title)
            
            // Always show RootView
            RootView()
            
            // Conditionally show AnotherRoot
            if Bool.random() {
                AnotherRoot()
            }
            
            // Randomly pick TertiaryRoot or a fallback text
            if Int.random(in: 0...1) == 0 {
                TertiaryRoot()
            } else {
                Text("TertiaryRoot not shown this time")
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Root View
// A primary branch that references MiddleView, SiblingView,
// and conditionally references a RepeatedChildrenHolder.
struct RootView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("RootView")
                .font(.headline)
            MiddleView()
            SiblingView()
            
            // Another conditional path to keep things interesting
            if Bool.random() {
                RepeatedChildrenHolder()
            }
        }
        .padding()
    }
}

// MARK: - MiddleView
// References two child views side by side, each nesting deeper.
struct MiddleView: View {
    var body: some View {
        HStack(spacing: 10) {
            ChildView1()
            ChildView2()
        }
    }
}

// MARK: - ChildView1, leads to GrandChild1 -> DeeperChild
struct ChildView1: View {
    var body: some View {
        VStack {
            Text("ChildView1")
                .bold()
            GrandChild1()
        }
        .padding(4)
        .border(Color.blue, width: 1)
    }
}

struct GrandChild1: View {
    var body: some View {
        VStack {
            Text("GrandChild1 Body")
            DeeperChild()
        }
        .padding(4)
        .border(Color.orange, width: 1)
    }
}

struct DeeperChild: View {
    var body: some View {
        Text("Deeper Child Level")
            .padding(4)
            .border(Color.purple, width: 1)
    }
}

// MARK: - ChildView2, leads to GrandChild2 -> DeeperChild
struct ChildView2: View {
    var body: some View {
        VStack {
            Text("ChildView2")
                .bold()
            GrandChild2()
        }
        .padding(4)
        .border(Color.green, width: 1)
    }
}

struct GrandChild2: View {
    var body: some View {
        VStack {
            Text("GrandChild2 Body")
            DeeperChild() // The same deeper child used by GrandChild1
        }
        .padding(4)
        .border(Color.red, width: 1)
    }
}

// MARK: - SiblingView
// Contains multiple repeated calls to AnotherChildView.
struct SiblingView: View {
    var body: some View {
        VStack {
            Text("SiblingView")
                .font(.headline)
            AnotherChildView()
            AnotherChildView()
        }
        .padding(4)
        .border(Color.gray, width: 1)
    }
}

// MARK: - AnotherChildView
// A simple repeated child that can appear multiple times.
struct AnotherChildView: View {
    var body: some View {
        Text("Hello from AnotherChildView")
            .padding(4)
            .border(Color.gray, width: 0.5)
    }
}

// MARK: - RepeatedChildrenHolder
// Dynamically creates a list of children using ForEach.
struct RepeatedChildrenHolder: View {
    let items = ["ItemA", "ItemB", "ItemC"]
    
    var body: some View {
        VStack {
            Text("RepeatedChildrenHolder")
                .font(.subheadline)
            
            ForEach(items, id: \.self) { item in
                DynamicChildView(label: item)
            }
        }
        .padding()
        .border(Color.mint, width: 1)
    }
}

struct DynamicChildView: View {
    let label: String
    
    var body: some View {
        Text("Dynamic child for \(label)")
            .padding(4)
            .border(Color.mint, width: 0.5)
    }
}

// MARK: - AnotherRoot
// A secondary top-level root, references SiblingView again.
struct AnotherRoot: View {
    var body: some View {
        VStack {
            Text("AnotherRoot")
                .font(.headline)
            SiblingView()
        }
        .padding()
        .border(Color.pink, width: 1)
    }
}

// MARK: - TertiaryRoot
// Another top-level root referencing a specialized subtree.
struct TertiaryRoot: View {
    var body: some View {
        VStack {
            Text("TertiaryRoot")
                .font(.headline)
            TertiaryChild()
        }
        .padding()
        .border(Color.yellow, width: 1)
    }
}

struct TertiaryChild: View {
    var body: some View {
        VStack {
            Text("TertiaryChild Body")
            ExpandingChild()
        }
        .padding(4)
        .border(Color.yellow, width: 0.5)
    }
}

// MARK: - ExpandingChild
// An additional deeper path that also references AnotherChildView repeatedly.
struct ExpandingChild: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("ExpandingChild Section")
                .bold()
            AnotherChildView()
            AnotherChildView()
            
            // Randomly add DeeperChild
            if Bool.random() {
                DeeperChild()
            }
        }
        .padding(4)
        .border(Color.yellow, width: 0.5)
    }
}
