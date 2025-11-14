import SwiftUI

struct VapiChatScreen: View {
    var body: some View {
        ZStack {
            // Abstract gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.3, blue: 0.9).opacity(0.8),
                    Color(red: 0.5, green: 0.2, blue: 0.8).opacity(0.6),
                    Color(red: 0.9, green: 0.1, blue: 0.5).opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Placeholder for future chat content
            Text("VapiChatScreen")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    VapiChatScreen()
}
