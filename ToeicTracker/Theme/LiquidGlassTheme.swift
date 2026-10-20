import SwiftUI

public enum LiquidGlassTheme {
    // Core Apple Dark Obsidian Canvas
    public static let background = Color(hex: 0x090D16)
    public static let backgroundSecondary = Color(hex: 0x0E1424)
    public static let surfaceGlass = Color.white.opacity(0.10)
    public static let surfaceGlassHeavy = Color(hex: 0x1E293B).opacity(0.20)
    public static let surfaceGlassLight = Color.white.opacity(0.18)

    // Borders & Specular Edges
    public static let glassBorder = Color.white.opacity(0.15)
    public static let glassBorderLight = Color.white.opacity(0.25)
    public static let glassBorderSubtle = Color.white.opacity(0.08)
    public static let crystalGlassBorder = Color.white.opacity(0.28)

    // Accent Brand Colors
    public static let primaryAccent = Color(hex: 0x6366F1) // Indigo
    public static let secondaryAccent = Color(hex: 0x06B6D4) // Cyan
    public static let purpleAccent = Color(hex: 0xA855F7) // Purple
    public static let emeraldAccent = Color(hex: 0x10B981) // Emerald Green
    public static let amberAccent = Color(hex: 0xF59E0B) // Amber
    public static let roseAccent = Color(hex: 0xF43F5E) // Rose

    // TOEIC Specific Colors
    public static let scoreTotal = Color(hex: 0x10B981)
    public static let scoreListening = Color(hex: 0x38BDF8)
    public static let scoreReading = Color(hex: 0xFB923C)
    public static let scoreSpeaking = Color(hex: 0xA855F7)
    public static let scoreWriting = Color(hex: 0xF43F5E)
    public static let streakFire = Color(hex: 0xF97316)

    // iOS Glass Gradients
    public static let glassSurfaceGradient = LinearGradient(
        colors: [
            Color(hex: 0x111827).opacity(0.92),
            Color(hex: 0x0F172A).opacity(0.96)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let glassCardGradient = LinearGradient(
        colors: [
            Color(hex: 0x161F33).opacity(0.85),
            Color(hex: 0x0F172A).opacity(0.92)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let crystalGlassGradient = LinearGradient(
        stops: [
            .init(color: Color.white.opacity(0.20), location: 0.0),
            .init(color: Color(hex: 0x38BDF8).opacity(0.08), location: 0.30),
            .init(color: Color(hex: 0x1E293B).opacity(0.12), location: 0.65),
            .init(color: Color(hex: 0x0F172A).opacity(0.25), location: 1.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let primaryButtonGradient = LinearGradient(
        colors: [Color(hex: 0x6366F1), Color(hex: 0x4F46E5)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let fireGradient = LinearGradient(
        colors: [Color(hex: 0xFFFF7A00), Color(hex: 0xFFFF3D00)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let cyanBlueGradient = LinearGradient(
        colors: [Color(hex: 0x06B6D4), Color(hex: 0x0284C7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let purpleGradient = LinearGradient(
        colors: [Color(hex: 0xA855F7), Color(hex: 0x7C3AED)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let amberGoldGradient = LinearGradient(
        colors: [Color(hex: 0xF59E0B), Color(hex: 0xD97706)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let emeraldGradient = LinearGradient(
        colors: [Color(hex: 0x10B981), Color(hex: 0x059669)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let borderHighlightGradient = LinearGradient(
        stops: [
            .init(color: Color.white.opacity(0.35), location: 0.0),
            .init(color: Color.white.opacity(0.06), location: 0.5),
            .init(color: Color.white.opacity(0.18), location: 1.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

public extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        if hex > 0xFFFFFF {
            // Hex with alpha: 0xAARRGGBB
            self.init(
                .sRGB,
                red: Double((hex >> 16) & 0xff) / 255.0,
                green: Double((hex >> 8) & 0xff) / 255.0,
                blue: Double(hex & 0xff) / 255.0,
                opacity: Double((hex >> 24) & 0xff) / 255.0
            )
        } else {
            self.init(
                .sRGB,
                red: Double((hex >> 16) & 0xff) / 255.0,
                green: Double((hex >> 8) & 0xff) / 255.0,
                blue: Double(hex & 0xff) / 255.0,
                opacity: alpha
            )
        }
    }
}
