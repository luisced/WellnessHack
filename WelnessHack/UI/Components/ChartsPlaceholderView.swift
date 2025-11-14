import SwiftUI

// MARK: - Weekly Analysis Chart Placeholder

struct WeeklyAnalysisChartView: View {
    let weeklyData: [WeeklyDataPoint]?
    
    init(weeklyData: [WeeklyDataPoint]? = nil) {
        self.weeklyData = weeklyData ?? generateSampleData()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            HStack {
                Text("Análisis Semanal")
                    .font(.headline)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Ver Detalles") {
                    // TODO: Navigate to detailed weekly analysis
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Chart Container
            chartContainer
            
            // Summary Stats
            weeklySummaryStats
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Chart Container
    
    private var chartContainer: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid lines
                Path { path in
                    let stepY = geometry.size.height / 4
                    for i in 0...4 {
                        let y = CGFloat(i) * stepY
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                }
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                
                // Chart line or bars (placeholder)
                if let data = weeklyData {
                    weeklyLineChart(data: data, geometry: geometry)
                } else {
                    placeholderChart(geometry: geometry)
                }
            }
        }
        .frame(height: 150)
    }
    
    // MARK: - Weekly Line Chart
    
    private func weeklyLineChart(data: [WeeklyDataPoint], geometry: GeometryProxy) -> some View {
        Path { path in
            guard !data.isEmpty else { return }
            
            let stepX = geometry.size.width / CGFloat(data.count - 1)
            let maxValue = data.map(\.value).max() ?? 100
            
            for (index, point) in data.enumerated() {
                let x = CGFloat(index) * stepX
                let y = geometry.size.height - (CGFloat(point.value / maxValue) * geometry.size.height)
                
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
        .stroke(
            LinearGradient(
                colors: [.cyan, .blue],
                startPoint: .leading,
                endPoint: .trailing
            ),
            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
        )
    }
    
    // MARK: - Placeholder Chart
    
    private func placeholderChart(geometry: GeometryProxy) -> some View {
        Path { path in
            let stepX = geometry.size.width / 6
            let points: [CGFloat] = [0.3, 0.5, 0.4, 0.7, 0.6, 0.8, 0.75]
            
            for (index, normalizedValue) in points.enumerated() {
                let x = CGFloat(index) * stepX
                let y = geometry.size.height - (normalizedValue * geometry.size.height)
                
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
        .stroke(
            LinearGradient(
                colors: [.white.opacity(0.6), .white.opacity(0.3)],
                startPoint: .leading,
                endPoint: .trailing
            ),
            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
        )
    }
    
    // MARK: - Weekly Summary Stats
    
    private var weeklySummaryStats: some View {
        HStack(spacing: 20) {
            StatItem(
                title: "Promedio",
                value: weeklyData?.map(\.value).reduce(0, +) / Double(weeklyData?.count ?? 1) ?? 65,
                unit: "%"
            )
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            StatItem(
                title: "Máximo",
                value: weeklyData?.map(\.value).max() ?? 85,
                unit: "%"
            )
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            StatItem(
                title: "Mínimo",
                value: weeklyData?.map(\.value).min() ?? 45,
                unit: "%"
            )
        }
    }
}

// MARK: - Pie Charts Analysis View

struct PieChartsAnalysisView: View {
    let pieChartData: [PieChartDataPoint]?
    
    init(pieChartData: [PieChartDataPoint]? = nil) {
        self.pieChartData = pieChartData ?? generateSamplePieData()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Análisis de Aspectos")
                .font(.headline)
                .foregroundColor(.white)
                .fontWeight(.semibold)
            
            // Pie Charts Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                if let data = pieChartData {
                    ForEach(data, id: \.id) { chartData in
                        PieChartCard(data: chartData)
                    }
                } else {
                    // Placeholder charts
                    PieChartCard(title: "Sueño", percentage: 0.75, color: .indigo)
                    PieChartCard(title: "Actividad", percentage: 0.60, color: .green)
                    PieChartCard(title: "Estrés", percentage: 0.30, color: .orange)
                    PieChartCard(title: "Nutrición", percentage: 0.80, color: .mint)
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Pie Chart Card

struct PieChartCard: View {
    let data: PieChartDataPoint?
    
    init(data: PieChartDataPoint? = nil, title: String = "", percentage: Double = 0.0, color: Color = .blue) {
        self.data = data ?? PieChartDataPoint(
            id: UUID(),
            title: title,
            percentage: percentage,
            color: color,
            description: "Análisis de \(title)"
        )
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Pie Chart
            pieChartView
            
            // Title and Value
            VStack(spacing: 4) {
                Text(data?.title ?? "Aspecto")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text("\(Int((data?.percentage ?? 0) * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(data?.color ?? .blue)
            }
            
            // Description
            Text(data?.description ?? "Descripción del análisis")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - Pie Chart View
    
    private var pieChartView: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 8)
                .frame(width: 60, height: 60)
            
            // Progress arc
            Circle()
                .trim(from: 0, to: data?.percentage ?? 0)
                .stroke(
                    data?.color ?? .blue,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: data?.percentage ?? 0)
        }
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let title: String
    let value: Double
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text("\(Int(value))\(unit)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Data Models

struct WeeklyDataPoint {
    let day: String
    let value: Double
}

struct PieChartDataPoint {
    let id: UUID
    let title: String
    let percentage: Double
    let color: Color
    let description: String
}

// MARK: - Sample Data Generators

private func generateSampleData() -> [WeeklyDataPoint] {
    let days = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"]
    return days.enumerated().map { index, day in
        WeeklyDataPoint(
            day: day,
            value: Double.random(in: 45...85)
        )
    }
}

private func generateSamplePieData() -> [PieChartDataPoint] {
    return [
        PieChartDataPoint(
            id: UUID(),
            title: "Sueño",
            percentage: 0.75,
            color: .indigo,
            description: "Calidad del descanso"
        ),
        PieChartDataPoint(
            id: UUID(),
            title: "Actividad",
            percentage: 0.60,
            color: .green,
            description: "Nivel de actividad física"
        ),
        PieChartDataPoint(
            id: UUID(),
            title: "Estrés",
            percentage: 0.30,
            color: .orange,
            description: "Nivel de estrés gestionado"
        ),
        PieChartDataPoint(
            id: UUID(),
            title: "Nutrición",
            percentage: 0.80,
            color: .mint,
            description: "Balance nutricional"
        )
    ]
}

// MARK: - Previews

#Preview("Weekly Analysis") {
    ZStack {
        Color.black.ignoresSafeArea()
        WeeklyAnalysisChartView()
    }
    .padding()
}

#Preview("Pie Charts") {
    ZStack {
        Color.black.ignoresSafeArea()
        PieChartsAnalysisView()
    }
    .padding()
}
