import SwiftUI
import SplineRuntime

struct FocusScreen: View {
    @StateObject private var viewModel = FocusViewModel()
    
    var body: some View {
        ZStack {
            // MARK: - Spline 3D Meditation Background
            
            if let url = Bundle.main.url(
                forResource: "meditation_copy",
                withExtension: "splineswift"
            ) {
                SplineView(sceneFileURL: url)
                    .ignoresSafeArea(.all) // Ignorar todos los bordes
                    .scaleEffect(2.2) // Círculo aún más grande
                    .clipped()
            } else {
                // Fallback gradient if Spline file not found
                LinearGradient(
                    colors: [
                        Color.focusBackground,
                        Color.focusBackground.opacity(0.8),
                        Color.black.opacity(0.9)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all)
            }
            
            // Overlay azul para bordes y mejor legibilidad
            Color.focusBlue.opacity(0.15)
                .ignoresSafeArea(.all)
            
            // MARK: - Content Overlay
            
            VStack(spacing: 0) {
                // MARK: - Title (centrado)
                titleView
                    .padding(.top, 60)
                
                // MARK: - Clock/Timer Section (centrado en pantalla)
                Spacer()
                
                centerContentView
                
                Spacer()
                
                // MARK: - Motivational Messages (más abajo)
                MotivationalMessagesView(messages: viewModel.currentMessages)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120) // Más espacio desde abajo
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onChange(of: viewModel.sessionType) { _ in
            // Actualizar mensajes cuando cambie el tipo de sesión
            viewModel.loadMotivationalMessages()
        }
    }
    
    // MARK: - Title View
    
    private var titleView: some View {
        // Título siempre en una línea (sin reloj pequeño)
        Text("TAKE A BREAK")
            .font(.system(size: viewModel.focusState == .idle ? 36 : 28, weight: .bold, design: .default))
            .foregroundColor(Color.focusBlue)
            .tracking(3)
    }
    
    // MARK: - Center Content (Clock or Timer)
    
    private var centerContentView: some View {
        ZStack {
            // Clock (idle state)
            if viewModel.focusState == .idle {
                ClockView(
                    isActive: true,
                    onTap: {
                        viewModel.onClockTapped()
                    }
                )
                .transition(.opacity)
            }
            
            // Timer (active states)
            if viewModel.focusState != .idle {
                VStack(spacing: 20) {
                    TimerCircleView(
                        timeRemaining: viewModel.timeRemaining,
                        totalTime: viewModel.totalTime,
                        isActive: viewModel.isTimerActive
                    )
                    .transition(.opacity)
                    
                    // Timer controls
                    timerControlsView
                }
            }
        }
        .animation(.easeInOut(duration: 0.8), value: viewModel.focusState)
    }
    
    // MARK: - Timer Controls
    
    private var timerControlsView: some View {
        HStack(spacing: 30) {
            // Pause/Resume button
            Button(action: {
                viewModel.togglePause()
            }) {
                Image(systemName: viewModel.isTimerActive ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.focusBlue)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Stop button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.6)) {
                    viewModel.stopSession()
                }
            }) {
                Image(systemName: "stop.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.7))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - Preview

#Preview {
    FocusScreen()
}

#Preview("Timer Active") {
    let viewModel = FocusViewModel()
    FocusScreen()
        .onAppear {
            viewModel.startFocusSession()
        }
}

#Preview("Timer Paused") {
    let viewModel = FocusViewModel()
    FocusScreen()
        .onAppear {
            viewModel.startFocusSession()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                viewModel.togglePause()
            }
        }
}
