import SwiftUI

public struct ChatBubbleView: View {
    public let message: MunAIChatMessage

    public var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if !message.isUser {
                // Mun AI Avatar
                ZStack {
                    Circle()
                        .fill(LiquidGlassTheme.purpleGradient)
                        .frame(width: 36, height: 36)
                        .shadow(color: LiquidGlassTheme.purpleAccent.opacity(0.4), radius: 6)

                    Text("🐱")
                        .font(.system(size: 18))
                }
            } else {
                Spacer()
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background {
                        if message.isUser {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(LiquidGlassTheme.primaryButtonGradient)
                        } else {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color(hex: 0x1E1B4B).opacity(0.65))
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(
                                message.isUser ? Color.white.opacity(0.25) : LiquidGlassTheme.purpleAccent.opacity(0.3),
                                lineWidth: 1.0
                            )
                    }
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 3)

                Text(message.timestamp, format: .dateTime.hour().minute())
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.horizontal, 4)
            }

            if message.isUser {
                // User Avatar
                ZStack {
                    Circle()
                        .fill(LiquidGlassTheme.primaryAccent.opacity(0.4))
                        .frame(width: 34, height: 34)

                    Image(systemName: "person.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                }
            } else {
                Spacer()
            }
        }
    }
}
