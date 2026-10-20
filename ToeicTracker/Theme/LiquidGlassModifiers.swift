import SwiftUI

public struct LiquidGlassBackground: ViewModifier {
    public var showOrbs: Bool

    public init(showOrbs: Bool = true) {
        self.showOrbs = showOrbs
    }

    public func body(content: Content) -> some View {
        ZStack {
            LiquidGlassTheme.background
                .ignoresSafeArea()

            if showOrbs {
                // Top-left glowing Indigo orb
                Circle()
                    .fill(Color(hex: 0x4F46E5).opacity(0.24))
                    .frame(width: 340, height: 340)
                    .blur(radius: 80)
                    .offset(x: -120, y: -260)

                // Top-right glowing Cyan orb
                Circle()
                    .fill(Color(hex: 0x06B6D4).opacity(0.18))
                    .frame(width: 300, height: 300)
                    .blur(radius: 70)
                    .offset(x: 140, y: -100)

                // Bottom-left Violet orb
                Circle()
                    .fill(Color(hex: 0x8B5CF6).opacity(0.16))
                    .frame(width: 320, height: 320)
                    .blur(radius: 80)
                    .offset(x: -100, y: 280)

                // Bottom-right Emerald orb
                Circle()
                    .fill(Color(hex: 0x10B981).opacity(0.14))
                    .frame(width: 280, height: 280)
                    .blur(radius: 75)
                    .offset(x: 120, y: 320)
            }

            // High contrast text protector
            Color.black.opacity(0.25)
                .ignoresSafeArea()

            content
        }
    }
}

public struct LiquidGlassCardModifier: ViewModifier {
    public var cornerRadius: CGFloat
    public var padding: CGFloat
    public var borderColor: Color
    public var borderWidth: CGFloat
    public var useUltraThinMaterial: Bool

    public init(
        cornerRadius: CGFloat = 22,
        padding: CGFloat = 16,
        borderColor: Color = LiquidGlassTheme.glassBorder,
        borderWidth: CGFloat = 1.0,
        useUltraThinMaterial: Bool = true
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.useUltraThinMaterial = useUltraThinMaterial
    }

    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(LiquidGlassTheme.glassCardGradient)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LiquidGlassTheme.borderHighlightGradient,
                        lineWidth: borderWidth
                    )
            }
            .shadow(color: Color.black.opacity(0.35), radius: 18, x: 0, y: 8)
            .shadow(color: LiquidGlassTheme.primaryAccent.opacity(0.06), radius: 10, x: 0, y: 2)
    }
}

// MARK: - View Extension Helpers
public extension View {
    func liquidGlassBackground(showOrbs: Bool = true) -> some View {
        modifier(LiquidGlassBackground(showOrbs: showOrbs))
    }

    func liquidGlassCard(
        cornerRadius: CGFloat = 22,
        padding: CGFloat = 16,
        borderColor: Color = LiquidGlassTheme.glassBorder,
        borderWidth: CGFloat = 1.0
    ) -> some View {
        modifier(LiquidGlassCardModifier(
            cornerRadius: cornerRadius,
            padding: padding,
            borderColor: borderColor,
            borderWidth: borderWidth
        ))
    }
}

// MARK: - Liquid Glass Chip Component
public struct LiquidGlassChipView: View {
    public let label: String
    public let value: String?
    public let accentColor: Color
    public let systemImage: String?
    public var action: (() -> Void)? = nil

    public init(
        label: String,
        value: String? = nil,
        accentColor: Color = LiquidGlassTheme.primaryAccent,
        systemImage: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.label = label
        self.value = value
        self.accentColor = accentColor
        self.systemImage = systemImage
        self.action = action
    }

    public var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(accentColor)
                }

                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))

                if let value {
                    Text(value)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(accentColor)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(accentColor.opacity(0.12))
            }
            .overlay {
                Capsule()
                    .strokeBorder(accentColor.opacity(0.35), lineWidth: 1.0)
            }
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}

// MARK: - Liquid Glass Button Component
public struct LiquidGlassButton: View {
    public let title: String
    public var icon: String? = nil
    public var gradient: LinearGradient = LiquidGlassTheme.primaryButtonGradient
    public var action: () -> Void

    public init(
        title: String,
        icon: String? = nil,
        gradient: LinearGradient = LiquidGlassTheme.primaryButtonGradient,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.gradient = gradient
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(gradient)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.32), lineWidth: 1.0)
            }
            .shadow(color: LiquidGlassTheme.primaryAccent.opacity(0.40), radius: 14, x: 0, y: 6)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

public struct ScaleButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
