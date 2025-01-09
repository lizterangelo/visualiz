import SwiftUI

struct DashboardView: View {
    let items: [String]

    var body: some View {
        ScrollView {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .padding()
            }
        }
    }
}

// A nested SwiftUI view that references DashboardView
struct DashboardWrapper: View {
    var body: some View {
        DashboardView(items: ["A", "B", "C"])
    }
}

