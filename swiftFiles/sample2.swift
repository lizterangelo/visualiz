import SwiftUI

// A top-level parent that decides which subviews to show.
// It references 'RootView' unconditionally, and sometimes
// references 'AnotherRoot' conditionally.
struct MainApp: View {
    var body: some View {
        VStack {
            RootView()
            
            // Conditional branch for complexity:
            if Bool.random() {
                AnotherRoot()
            }
        }
    }
}

// Another top-level view that references 'SiblingView'.
struct AnotherRoot: View {
    var body: some View {
        SiblingView()
    }
}

// The primary "root" branch in this hierarchy, referencing
// a MiddleView and then a SiblingView on the same level.
struct RootView: View {
    var body: some View {
        VStack {
            MiddleView()
            SiblingView()
        }
    }
}

// A view that references two children side by side (ChildView1 and ChildView2).
struct MiddleView: View {
    var body: some View {
        HStack {
            ChildView1()
            ChildView2()
        }
    }
}

// First child leads to a grandchild; demonstrates nesting.
struct ChildView1: View {
    var body: some View {
        GrandChild1()
    }
}

// Second child leads to another grandchild; demonstrates deeper layers as well.
struct ChildView2: View {
    var body: some View {
        GrandChild2()
    }
}

// A grandchild that, in turn, references a deeper child view.
struct GrandChild1: View {
    var body: some View {
        VStack {
            Text("GrandChild1 Body")
            DeeperChild()
        }
    }
}

// Another grandchild with a different layout but references the same deeper child.
struct GrandChild2: View {
    var body: some View {
        HStack {
            Text("GrandChild2 Body")
            DeeperChild()
        }
    }
}

// A deeper child shared by both GrandChild1 and GrandChild2.
struct DeeperChild: View {
    var body: some View {
        Text("Deeper Child Level")
    }
}

// A sibling branch used by both 'RootView' and 'AnotherRoot',
// referencing 'AnotherChildView' multiple times.
struct SiblingView: View {
    var body: some View {
        VStack {
            AnotherChildView()
            AnotherChildView()
        }
    }
}

// A repeated child that can appear multiple times in SiblingView.
struct AnotherChildView: View {
    var body: some View {
        Text("Hello from AnotherChildView")
    }
}
