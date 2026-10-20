import SwiftUI

public struct DynamicIslandNotificationBanner: View {
    public let notification: AppBannerNotification
    public var onDismiss: () -> Void

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: notification.type.systemIcon)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(notification.type.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)

                Text(notification.message)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(2)
            }

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(6)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(hex: 0x0E1424).opacity(0.96))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(notification.type.color.opacity(0.4), lineWidth: 1.2)
        }
        .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 10)
        .shadow(color: notification.type.color.opacity(0.2), radius: 12, x: 0, y: 4)
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }
}
