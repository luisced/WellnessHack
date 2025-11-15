import SwiftUI
import SplineRuntime

struct FocusScreen: View {
    @StateObject private var viewModel = FocusViewModel()
    @State private var showBreak = false
    var body: some View {
        // MARK: - Content with Spline Background
        
        ZStack {
            // MARK: - Spline Background (fondo completo)
            backgroundView
            
            if showBreak {
                BreakScreen(onBackToMain: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showBreak = false
                    }
                })
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                // MARK: - Content
                VStack(spacing: 0) {
                    // MARK: - Title (centrado y estático)
                    titleView
                        .padding(.top, 140)
                    
                    // MARK: - Clock/Timer Section (centrado en pantalla)
                    Spacer()
                    BatteryChargingView(
                        batteryLevel: viewModel.batteryLevel,
                        onBreakRequested: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showBreak = true
                            }
                        }
                    )
                    
    //                centerContentView
                    
                    Spacer()
                    
                    // MARK: - Motivational Messages (más abajo)
                    MotivationalMessagesView(messages: viewModel.currentMessages)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 170) // Aumentado para no estar tapado por tab bar
                }
            }
        }
        .ignoresSafeArea(.all)
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
    
    // MARK: - Background View
    
    private var backgroundView: some View {
        ZStack {
            // MARK: - Spline 3D Meditation Background
            
            if let url = Bundle.main.url(
                forResource: "meditation_copy",
                withExtension: "splineswift"
            ) {
                SplineView(sceneFileURL: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaleEffect(2.8)
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
        }
    }
    
    // MARK: - Title View
    
    private var titleView: some View {
        // Título estático (sin cambios de tamaño)
        Text("Body Battery")
            .font(.system(size: 36, weight: .bold, design: .default))
            .foregroundColor(Color.calendarMint.opacity(0.7))
            .tracking(3)
    }
    
    // MARK: - Center Content (Clock or Timer)
    
    private var centerContentView: some View {
        // Contenedor con ALTURA FIJA TOTAL para mantener posición consistente
        VStack(spacing: 0) {
            // Clock or Timer (centered) - SIEMPRE en la misma posición
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
                
                // Timer (active states) - exactamente en la misma posición
                if viewModel.focusState != .idle {
                    TimerCircleView(
                        timeRemaining: viewModel.timeRemaining,
                        totalTime: viewModel.totalTime,
                        isActive: viewModel.isTimerActive
                    )
                    .transition(.opacity)
                }
            }
            .frame(height: 200)
            .animation(.easeInOut(duration: 0.8), value: viewModel.focusState)
            
            // Espaciado entre reloj/timer y controles
            Spacer()
                .frame(height: 20)
            
            // Timer controls con altura fija (60pt cuando visible, 60pt vacío cuando no)
            Group {
                if viewModel.focusState != .idle {
                    timerControlsView
                        .transition(.opacity)
                } else {
                    // Espacio vacío del mismo tamaño para mantener altura total
                    Color.clear
                        .frame(height: 60)
                }
            }
            .frame(height: 60)
        }
        .frame(height: 280) // ALTURA TOTAL FIJA: 200 (reloj) + 20 (espacio) + 60 (controles)
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
                    .foregroundColor(.calendarMint)
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
