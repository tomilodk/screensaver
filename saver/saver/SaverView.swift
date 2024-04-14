import Foundation
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
        logMessage("Setting up Shaders")
        
        glContext?.makeCurrentContext()  // Ensure the OpenGL context is current

        // Vertex shader source code
        let vertexShaderSource = """
        #version 410 core
        layout(location = 0) in vec4 position;
        void main() {
            gl_Position = position;  // Pass through vertex position
        }
        """

        // Fragment shader source code that outputs a static green color
        let fragmentShaderSource = """
        #version 410 core
        out vec4 fragColor;
        void main() {
            fragColor = vec4(0.0, 1.0, 0.0, 1.0);  // Output green color
        }
        """

        // Create and compile the vertex shader
        let vertexShader = compileShader(vertexShaderSource, type: GLenum(GL_VERTEX_SHADER))
        // Create and compile the fragment shader
        let fragmentShader = compileShader(fragmentShaderSource, type: GLenum(GL_FRAGMENT_SHADER))

        // Create a shader program and attach shaders
        shaderProgram = glCreateProgram()
        glAttachShader(shaderProgram, vertexShader)
        glAttachShader(shaderProgram, fragmentShader)

        // Link and use the shader program
        linkProgram(shaderProgram)

        // Delete shaders after linking (they are no longer needed)
        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShader)
    }

    func compileShader(_ source: String, type: GLenum) -> GLuint {
        let shader = glCreateShader(type)
        var sourceUTF8 = (source as NSString).utf8String
        glShaderSource(shader, 1, &sourceUTF8, nil)
        glCompileShader(shader)

        // Check for compile errors
        var compileStatus: GLint = 0
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &compileStatus)
        if compileStatus == GL_FALSE {
            var infoLog = [GLchar](repeating: GLchar(0), count: 512)
            glGetShaderInfoLog(shader, GLsizei(infoLog.count), nil, &infoLog)
            let infoLogString = String(cString: infoLog)
            print("Shader compile error: \(infoLogString)")
        }

        return shader
    }

    func linkProgram(_ prog: GLuint) {
        glLinkProgram(prog)

        // Check for linking errors
        var linkStatus: GLint = 0
        glGetProgramiv(prog, GLenum(GL_LINK_STATUS), &linkStatus)
        if linkStatus == GL_FALSE {
            var infoLog = [GLchar](repeating: GLchar(0), count: 512)
            glGetProgramInfoLog(prog, GLsizei(infoLog.count), nil, &infoLog)
            let infoLogString = String(cString: infoLog)
            print("Program link error: \(infoLogString)")
        }
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


    override func draw(_ rect: NSRect) {
        super.draw(rect)
        glContext?.makeCurrentContext()
        
        glViewport(0, 0, GLsizei(rect.width), GLsizei(rect.height))  // Set the viewport size to match the view
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
    
    

    func logMessage(_ message: String) {
        let fileName = "saverLog.txt"
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        
        let logMessage = "\(timestamp): \(message)\n"
        
        // Attempt to write to the file
        if FileManager.default.fileExists(atPath: fileURL.path) {
            // If file exists, append the log message
            do {
                let fileHandle = try FileHandle(forWritingTo: fileURL)
                fileHandle.seekToEndOfFile()
                fileHandle.write(logMessage.data(using: .utf8)!)
                fileHandle.closeFile()
            } catch {
                print("Unable to write to log file: \(error)")
            }
        } else {
            // If file does not exist, try to create it
            do {
                try logMessage.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                print("Unable to create log file: \(error)")
            }
        }
    }
}

extension Array {
    var sizeInBytes: Int {
        return count * MemoryLayout<Element>.stride
    }
}
