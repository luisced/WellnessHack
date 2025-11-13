import Foundation

enum EnvLoader {
    
    // MARK: - Load Environment Variables
    
    static func loadEnv() {
        guard let envPath = Bundle.main.path(forResource: ".env", ofType: nil) else {
            print("⚠️ .env file not found in bundle")
            return
        }
        
        do {
            let envContent = try String(contentsOfFile: envPath, encoding: .utf8)
            let lines = envContent.components(separatedBy: .newlines)
            
            for line in lines {
                // Skip empty lines and comments
                let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") {
                    continue
                }
                
                // Parse KEY=VALUE
                let parts = trimmedLine.components(separatedBy: "=")
                guard parts.count == 2 else { continue }
                
                let key = parts[0].trimmingCharacters(in: .whitespaces)
                let value = parts[1].trimmingCharacters(in: .whitespaces)
                
                // Set as environment variable
                setenv(key, value, 1)
                
                print("✅ Loaded env variable: \(key)")
            }
        } catch {
            print("❌ Error loading .env file: \(error)")
        }
    }
    
    // MARK: - Get Environment Variable
    
    static func get(_ key: String) -> String? {
        return ProcessInfo.processInfo.environment[key]
    }
    
    // MARK: - Validate Required Variables
    
    static func validateRequiredVariables() -> Bool {
        let required = ["ELEVENLABS_API_KEY", "ELEVENLABS_AGENT_ID"]
        var allPresent = true
        
        for key in required {
            if get(key)?.isEmpty ?? true {
                print("❌ Missing required environment variable: \(key)")
                allPresent = false
            }
        }
        
        return allPresent
    }
}

