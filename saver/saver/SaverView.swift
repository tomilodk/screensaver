import Cocoa
import OpenGL.GL3
import ScreenSaver
import SwiftUI

class SaverView: ScreenSaverView {
    var glContext: NSOpenGLContext?
    var vertexArrayObject: GLuint = 0
    var vertexBuffer: GLuint = 0
    var shaderProgram: GLuint = 0

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        initializeOpenGL()
        setupShaders()
        setupVertexBuffer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeOpenGL()
        setupShaders()
        setupVertexBuffer()
    }

    func initializeOpenGL() {
        let attributes: [NSOpenGLPixelFormatAttribute] = [
            UInt32(NSOpenGLPFAAccelerated),
            UInt32(NSOpenGLPFAColorSize), 24,
            UInt32(NSOpenGLPFADepthSize), 32,
            UInt32(NSOpenGLPFAOpenGLProfile),
            UInt32(NSOpenGLProfileVersion4_1Core),
            0
        ]
        let pixelFormat = NSOpenGLPixelFormat(attributes: attributes)!
        glContext = NSOpenGLContext(format: pixelFormat, share: nil)
        glContext?.view = self
    }

    func setupShaders() {
        let vertexShaderSource = """
        #version 410 core
        layout(location = 0) in vec4 position;
        void main() {
            gl_Position = position;
        }
        """
        // Use UserDefaults to get the stored fragment shader code
        let defaults = UserDefaults(suiteName: "com.mappso.saver")!
        let fragmentShaderSource = defaults.string(forKey: "shaderCode") ?? ""

        shaderProgram = glCreateProgram()
        let vertShader = compileShader(vertexShaderSource, type: GLenum(GL_VERTEX_SHADER))
        let fragShader = compileShader(fragmentShaderSource, type: GLenum(GL_FRAGMENT_SHADER))
        
        glAttachShader(shaderProgram, vertShader)
        glAttachShader(shaderProgram, fragShader)
        glLinkProgram(shaderProgram)
        glUseProgram(shaderProgram)

        glDeleteShader(vertShader)
        glDeleteShader(fragShader)
    }

    func setupVertexBuffer() {
        let vertices: [GLfloat] = [
            -1.0, -1.0, 0.0, 1.0,
             1.0, -1.0, 0.0, 1.0,
             1.0,  1.0, 0.0, 1.0,
            -1.0,  1.0, 0.0, 1.0
        ]

        glGenVertexArrays(1, &vertexArrayObject)
        glBindVertexArray(vertexArrayObject)

        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), vertices.sizeInBytes, vertices, GLenum(GL_STATIC_DRAW))

        glVertexAttribPointer(0, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 4), nil)
        glEnableVertexAttribArray(0)

        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArray(0)
    }

    func compileShader(_ source: String, type: GLenum) -> GLuint {
        let shader = glCreateShader(type)
        var sourceUTF8 = (source as NSString).utf8String
        glShaderSource(shader, 1, &sourceUTF8, nil)
        glCompileShader(shader)

        // Error handling omitted for brevity
        return shader
    }

    override func draw(_ rect: NSRect) {
        super.draw(rect)
        glContext?.makeCurrentContext()
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        glUseProgram(shaderProgram)
        glBindVertexArray(vertexArrayObject)
        glDrawArrays(GLenum(GL_TRIANGLE_FAN), 0, 4)
        glBindVertexArray(0)

        glContext?.flushBuffer()
    }

    override func animateOneFrame() {
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

extension Array {
    var sizeInBytes: Int {
        return count * MemoryLayout<Element>.stride
    }
}
