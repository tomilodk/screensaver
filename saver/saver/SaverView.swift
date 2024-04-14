import ScreenSaver
import SwiftUI

class SaverView: ScreenSaverView {
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

        //Fill with yellow
        NSColor.yellow.setFill()
        screenRect.fill()
    }
    
    override func animateOneFrame() {
        super.animateOneFrame()
        self.needsDisplay = true
    }
    
    override var hasConfigureSheet: Bool {
        return true
    }

    var configWindow: NSWindow?

    override var configureSheet: NSWindow? {
        if configWindow == nil {
            let hostingController = NSHostingController(rootView: ConfigView(closeAction: {
                self.closeConfigWindow()
            }))
            configWindow = NSWindow(contentViewController: hostingController)
            configWindow?.setContentSize(NSSize(width: 300, height: 200))
            print("Window created")  // Debug statement
        }
        return configWindow
    }

    func closeConfigWindow() {
        print("Attempting to close window")  // Debug statement
        configWindow?.orderOut(nil)  // Explicitly removing the window from display
        configWindow?.close()
        configWindow = nil
    }

}
