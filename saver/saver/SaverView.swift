import ScreenSaver
import SwiftUI

class SaverView: ScreenSaverView {
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        self.animationTimeInterval = 1.0 / 30.0
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func startAnimation() {
        super.startAnimation()
    }
    
    override func stopAnimation() {
        super.stopAnimation()
    }
    
    override func draw(_ rect: NSRect) {
        super.draw(rect)
    }
    
    override func animateOneFrame() {
        NSColor.blue.setFill()
        let rect = NSBezierPath(rect: bounds)
        rect.fill()
        super.animateOneFrame()
        setNeedsDisplay(bounds)  // Force the view to redraw
    }
    
    override var hasConfigureSheet: Bool {
        return true
    }

    override var configureSheet: NSWindow? {
        let hostingController = NSHostingController(rootView: ConfigView())
        let window = NSWindow(contentViewController: hostingController)
        window.setContentSize(NSSize(width: 300, height: 200))
        return window
    }
}
