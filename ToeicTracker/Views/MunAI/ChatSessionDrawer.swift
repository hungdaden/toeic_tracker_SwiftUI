import SwiftUI

public struct ChatSessionDrawer: View {
    @ObservedObject public var munAIVM: MunAIViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var apiKeyInput: String = ""
    @State private var showApiKeySection: Bool = false

    public var body: some View {
        VStack(spacing: 18) {
            // Header
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)

                HStack {
                    HStack(spacing: 8) {
                        Text("🐱")
                            .font(.system(size: 20))
                        Text("Lịch Sử Tư Vấn")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    Button {
                        munAIVM.createNewSession()
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("Phiên mới")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(LiquidGlassTheme.purpleGradient))
                    }
                }
                .padding(.horizontal, 20)
            }

            // Sessions List
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(munAIVM.sessions) { session in
                        let isSelected = session.id == munAIVM.currentSession.id

                        HStack(spacing: 12) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(isSelected ? LiquidGlassTheme.purpleAccent : .white.opacity(0.4))

                            VStack(alignment: .leading, spacing: 3) {
                                Text(session.title)
                                    .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                                    .foregroundStyle(isSelected ? .white : .white.opacity(0.8))
                                    .lineLimit(1)

                                Text(session.createdAt, format: .dateTime.day().month().hour().minute())
                                    .font(.system(size: 11))
                                    .foregroundStyle(.white.opacity(0.4))
                            }

                            Spacer()

                            if munAIVM.sessions.count > 1 {
                                Button {
                                    munAIVM.deleteSession(id: session.id)
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 12))
                                        .foregroundStyle(.white.opacity(0.3))
                                        .padding(6)
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isSelected ? LiquidGlassTheme.purpleAccent.opacity(0.18) : Color.white.opacity(0.04))
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isSelected ? LiquidGlassTheme.purpleAccent.opacity(0.4) : Color.white.opacity(0.08), lineWidth: 1)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            munAIVM.switchSession(to: session)
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            // Gemini API Key Settings
            VStack(alignment: .leading, spacing: 8) {
                Button {
                    withAnimation {
                        showApiKeySection.toggle()
                    }
                } label: {
                    HStack {
                        Image(systemName: "key.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(LiquidGlassTheme.amberAccent)
                        Text("Cấu hình Google Gemini API Key")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))
                        Spacer()
                        Image(systemName: showApiKeySection ? "chevron.up" : "chevron.down")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
                }

                if showApiKeySection {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nhập API Key từ Google AI Studio nếu muốn kết nối trực tiếp mô hình Gemini 2.0 Flash (nếu để trống app sẽ dùng trợ lý Mun AI Offline thông minh):")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.6))

                        HStack {
                            SecureField("AIzaSy...", text: $apiKeyInput)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundStyle(.white)
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.08)))

                            Button("Lưu") {
                                StorageService.shared.setGeminiApiKey(apiKeyInput)
                                withAnimation {
                                    showApiKeySection = false
                                }
                            }
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(LiquidGlassTheme.primaryButtonGradient))
                        }
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.04)))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .background(Color(hex: 0x090D16).ignoresSafeArea())
        .onAppear {
            apiKeyInput = StorageService.shared.getGeminiApiKey()
        }
    }
}
