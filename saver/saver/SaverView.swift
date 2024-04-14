import ScreenSaver
import SwiftUI

class SaverView: ScreenSaverView {
    var context: CGContext! = nil
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)!

        self.animationTimeInterval = TimeInterval(1)
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
    
    override func draw(_ screenRect: NSRect) {
        super.draw(screenRect)

        context = NSGraphicsContext.current!.cgContext


        /*
         * Draw the screen background (color)
         */
        context.saveGState()
        context.setFillColor(NSColor.white.cgColor)
        context.fill(self.bounds)
        context.restoreGState()


    }
    
    override func animateOneFrame() {
        needsDisplay = true
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
