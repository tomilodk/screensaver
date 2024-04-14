import Foundation
import Combine
import SwiftUI

class ConfigViewModel: ObservableObject {
    @Published var shadertoyShaderID: String = ""
    @Published var shadertoyApiKey: String = ""
    @Published var statusMessage: String = ""
    
    private let myModuleName = "com.mappso.saver"
    private var cancellables: Set<AnyCancellable> = []

    init() {
        loadDefaults()
    }
    
    private func loadDefaults() {
        let defaults = UserDefaults(suiteName: myModuleName)!
        shadertoyShaderID = defaults.string(forKey: "ShadertoyShaderID") ?? ""
        shadertoyApiKey = defaults.string(forKey: "ShadertoyApiKey") ?? ""
    }
    
    func saveSettings() {
        let defaults = UserDefaults(suiteName: myModuleName)!
        defaults.set(shadertoyShaderID, forKey: "ShadertoyShaderID")
        defaults.set(shadertoyApiKey, forKey: "ShadertoyApiKey")
        
        fetchShaderData()
    }

    private func fetchShaderData() {
        let requestUrl = createRequestString(shaderId: shadertoyShaderID, apiKey: shadertoyApiKey)
        guard let url = URL(string: requestUrl) else {
            self.statusMessage = "Invalid URL"
            return
        }

        let session = URLSession.shared
        let request = URLRequest(url: url)

        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                    self.statusMessage = "Error from Shadertoy: \(error?.localizedDescription ?? "Unknown error")"
                    return
                }

                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let shaderCode = self.getShaderString(from: jsonObject) {
                            UserDefaults(suiteName: self.myModuleName)?.set(shaderCode, forKey: "shaderCode")
                            self.statusMessage = "Successfully extraded code: \(shaderCode)"
                        } else {
                            self.statusMessage = "Failed to extract shader code"
                        }
                    }
                } catch {
                    self.statusMessage = "Failed to decode response"
                }
            }
        }.resume()
    }

    func getShaderString(from shaderInfo: [String: Any]) -> String? {
        guard let shader = shaderInfo["Shader"] as? [String: Any],
              let renderPasses = shader["renderpass"] as? [[String: Any]],
              let firstRenderPass = renderPasses.first,
              let code = firstRenderPass["code"] as? String else {
            return nil
        }
        return code
    }

    private func createRequestString(shaderId: String, apiKey: String) -> String {
        return "https://www.shadertoy.com/api/v1/shaders/\(shaderId)?key=\(apiKey)"
    }
}
