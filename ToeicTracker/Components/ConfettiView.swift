import SwiftUI

public struct ConfettiView: View {
    @Binding public var isPresented: Bool
    @State private var particles: [ConfettiParticle] = []

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(particles) { p in
                    Rectangle()
                        .fill(p.color)
                        .frame(width: p.size, height: p.size * 0.6)
                        .rotationEffect(.degrees(p.rotation))
                        .position(p.position)
                        .opacity(p.opacity)
                }
            }
            .onAppear {
                spawnParticles(in: proxy.size)
            }
        }
        .allowsHitTesting(false)
    }

    private func spawnParticles(in size: CGSize) {
        let colors: [Color] = [
            LiquidGlassTheme.primaryAccent,
            LiquidGlassTheme.secondaryAccent,
            LiquidGlassTheme.emeraldAccent,
            LiquidGlassTheme.amberAccent,
            LiquidGlassTheme.purpleAccent,
            LiquidGlassTheme.roseAccent,
            Color.yellow
        ]

        var newParticles: [ConfettiParticle] = []
        for _ in 0..<70 {
            let startX = CGFloat.random(in: 40...(size.width - 40))
            let startY = CGFloat.random(in: -20...60)
            let endX = startX + CGFloat.random(in: -100...100)
            let endY = size.height + CGFloat.random(in: 20...120)

            let p = ConfettiParticle(
                position: CGPoint(x: startX, y: startY),
                color: colors.randomElement() ?? .cyan,
                size: CGFloat.random(in: 8...14),
                rotation: Double.random(in: 0...360)
            )
            newParticles.append(p)
        }
        particles = newParticles

        withAnimation(.easeOut(duration: 3.5)) {
            for i in 0..<particles.count {
                let endX = particles[i].position.x + CGFloat.random(in: -80...80)
                let endY = size.height + CGFloat.random(in: 20...100)
                particles[i].position = CGPoint(x: endX, y: endY)
                particles[i].rotation += Double.random(in: 360...1080)
                particles[i].opacity = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.6) {
            isPresented = false
        }
    }
}

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    var size: CGFloat
    var rotation: Double
    var opacity: Double = 1.0
}
