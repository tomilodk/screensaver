import SwiftUI
import ScreenSaver

struct SaverViewRepresentable: NSViewRepresentable {
    var isAnimating: Bool

    func makeNSView(context: Context) -> SaverView {
        SaverView(frame: .zero, isPreview: false)!
    }
    
    func updateNSView(_ nsView: SaverView, context: Context) {
        if isAnimating {
            nsView.startAnimation()
        } else {
            nsView.stopAnimation()
        }
    }
}
