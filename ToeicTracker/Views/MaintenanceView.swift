import SwiftUI

public struct MaintenanceView: View {
    @ObservedObject public var authService: AuthService

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(LiquidGlassTheme.amberAccent.opacity(0.18))
                    .frame(width: 90, height: 90)

                Image(systemName: "wrench.and.screwdriver.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(LiquidGlassTheme.amberAccent)
            }

            VStack(spacing: 8) {
                Text("Hệ Thống Đang Bảo Trì")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)

                Text("Quản trị viên vừa kích hoạt chế độ bảo trì định kỳ để nâng cấp hệ thống. Vui lòng quay lại sau ít phút nhé!")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 24)

            Button {
                Task {
                    await authService.checkMaintenanceMode()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Kiểm tra lại")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 14).fill(LiquidGlassTheme.primaryButtonGradient))
            }
            .buttonStyle(ScaleButtonStyle())

            Spacer()
        }
        .liquidGlassBackground()
    }
}
