import SwiftUI

@main
struct WelnessHackApp: App {
    
    init() {
        // Load environment variables from .env file
        EnvLoader.loadEnv()
        
        // Validate required variables
        if !EnvLoader.validateRequiredVariables() {
            print("⚠️ Some required environment variables are missing")
            print("📝 Create a .env file in the project root with:")
            print("   ELEVENLABS_API_KEY=your_api_key")
            print("   ELEVENLABS_AGENT_ID=your_agent_id")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
