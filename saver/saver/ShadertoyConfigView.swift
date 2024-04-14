import SwiftUI

struct ConfigView: View {
    @StateObject private var viewModel = ConfigViewModel()
    var closeAction: () -> Void

    var body: some View {
        Form {
            TextField("Shader ID", text: $viewModel.shadertoyShaderID)
            TextField("API Key", text: $viewModel.shadertoyApiKey)
            Text(viewModel.statusMessage).foregroundColor(.red)
            Button("Save") {
                viewModel.saveSettings()
            }
            Button("Close") {
                self.closeAction()
            }
        }
        .padding()
        .frame(width: 300, height: 200)
    }
}
