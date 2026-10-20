import SwiftUI

public struct CircularScoreGaugeView: View {
    public let currentScore: Int
    public let targetScore: Int
    public var size: CGFloat = 130
    public var strokeWidth: CGFloat = 12

    public var progress: Double {
        guard targetScore > 0 else { return 0 }
        return min(max(Double(currentScore) / Double(targetScore), 0.0), 1.0)
    }

    public var body: some View {
        ZStack {
            // Track circle
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: strokeWidth)
                .frame(width: size, height: size)

            // Progress circle
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(
                    AngularGradient(
                        colors: [
                            LiquidGlassTheme.secondaryAccent,
                            LiquidGlassTheme.primaryAccent,
                            LiquidGlassTheme.scoreTotal
                        ],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: size, height: size)
                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: progress)
                .shadow(color: LiquidGlassTheme.scoreTotal.opacity(0.4), radius: 8, x: 0, y: 0)

            // Center text
            VStack(spacing: 2) {
                Text("\(currentScore)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("/ \(targetScore)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))

                Text("\(Int(progress * 100))%")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(LiquidGlassTheme.scoreTotal)
            }
        }
    }
}
