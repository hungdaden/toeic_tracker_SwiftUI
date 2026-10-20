import SwiftUI
import Charts

public struct ScoreChartView: View {
    public let scores: [ToeicScore]
    public let targetScore: Int
    public let isFourSkills: Bool

    @State private var selectedScore: ToeicScore?

    private var sortedScores: [ToeicScore] {
        scores.sorted(by: { $0.date < $1.date })
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header with title and legend
            HStack {
                Text("Tiến Trình Điểm Số")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                HStack(spacing: 10) {
                    LegendItem(color: LiquidGlassTheme.scoreListening, label: "Nghe")
                    LegendItem(color: LiquidGlassTheme.scoreReading, label: "Đọc")
                    LegendItem(color: LiquidGlassTheme.scoreTotal, label: "Tổng")
                }
            }

            if sortedScores.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 36))
                        .foregroundStyle(.white.opacity(0.3))
                    Text("Chưa có dữ liệu bài thi nào.")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity, minHeight: 180)
            } else {
                Chart {
                    // Target score rule mark
                    RuleMark(y: .value("Mục tiêu", targetScore))
                        .lineStyle(StrokeStyle(lineWidth: 1.2, dash: [5, 5]))
                        .foregroundStyle(LiquidGlassTheme.amberAccent.opacity(0.75))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Mục tiêu: \(targetScore)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(LiquidGlassTheme.amberAccent)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.black.opacity(0.6)))
                        }

                    // Series lines and points
                    ForEach(sortedScores) { s in
                        // Listening series
                        LineMark(
                            x: .value("Ngày", s.date),
                            y: .value("Điểm", s.listeningScore),
                            series: .value("Kỹ năng", "Listening")
                        )
                        .foregroundStyle(LiquidGlassTheme.scoreListening)
                        .interpolationMethod(.monotone)

                        PointMark(
                            x: .value("Ngày", s.date),
                            y: .value("Điểm", s.listeningScore)
                        )
                        .foregroundStyle(LiquidGlassTheme.scoreListening)
                        .symbolSize(32)

                        // Reading series
                        LineMark(
                            x: .value("Ngày", s.date),
                            y: .value("Điểm", s.readingScore),
                            series: .value("Kỹ năng", "Reading")
                        )
                        .foregroundStyle(LiquidGlassTheme.scoreReading)
                        .interpolationMethod(.monotone)

                        PointMark(
                            x: .value("Ngày", s.date),
                            y: .value("Điểm", s.readingScore)
                        )
                        .foregroundStyle(LiquidGlassTheme.scoreReading)
                        .symbolSize(32)

                        // Total score series
                        let total = s.calculateTotal(isFourSkills: isFourSkills)
                        LineMark(
                            x: .value("Ngày", s.date),
                            y: .value("Điểm", total),
                            series: .value("Kỹ năng", "Total")
                        )
                        .foregroundStyle(LiquidGlassTheme.scoreTotal)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                        .interpolationMethod(.monotone)

                        PointMark(
                            x: .value("Ngày", s.date),
                            y: .value("Điểm", total)
                        )
                        .foregroundStyle(LiquidGlassTheme.scoreTotal)
                        .symbolSize(44)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.white.opacity(0.1))
                        AxisValueLabel()
                            .foregroundStyle(Color.white.opacity(0.6))
                            .font(.system(size: 10))
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.white.opacity(0.08))
                        AxisValueLabel(format: .dateTime.month().day())
                            .foregroundStyle(Color.white.opacity(0.6))
                            .font(.system(size: 10))
                    }
                }
                .frame(height: 200)
            }
        }
        .liquidGlassCard(cornerRadius: 22, padding: 18)
    }
}

private struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.75))
        }
    }
}
