import Foundation
import Combine

class ConfigViewModel: ObservableObject {
    @Published var shadertoyShaderID: String = ""
    @Published var shadertoyApiKey: String = ""
    @Published var statusMessage: String = ""
    
    private let myModuleName = "diracdrifter.Shadertoy-Screensaver"
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
        let baseUrl = "https://www.shadertoy.com/api/v1/shaders/"
        guard let url = URL(string: "\(baseUrl)\(shadertoyShaderID)?key=\(shadertoyApiKey)") else {
            statusMessage = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: String.self, decoder: JSONDecoder()) // Assuming the data is directly decodable to String, adjust based on actual data format
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.statusMessage = "Fetching shader was successful"
                case .failure(let error):
                    self.statusMessage = "Error fetching shader: \(error.localizedDescription)"
                }
            }, receiveValue: { shaderJson in
                let defaults = UserDefaults(suiteName: self.myModuleName)!
                defaults.set(shaderJson, forKey: "ShaderJSON")
            })
            .store(in: &cancellables)
    }
}
