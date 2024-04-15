import SwiftUI

struct ContentView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack {
            SaverViewRepresentable(isAnimating: isAnimating)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button(isAnimating ? "Stop" : "Start") {
                isAnimating.toggle()
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }
    }
}
