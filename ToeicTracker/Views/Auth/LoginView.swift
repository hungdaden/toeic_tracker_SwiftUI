import SwiftUI

public struct LoginView: View {
    @ObservedObject public var userVM: UserViewModel
    @State private var emailOrUsername: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoginMode: Bool = true
    @State private var errorMessage: String?

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 30)

                // App Brand Hero
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LiquidGlassTheme.primaryButtonGradient)
                            .frame(width: 80, height: 80)
                            .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1.5))
                            .shadow(color: LiquidGlassTheme.primaryAccent.opacity(0.5), radius: 16)

                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 38))
                            .foregroundStyle(.white)
                    }

                    Text("TOEIC Tracker")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Hệ thống quản lý điểm thi & Trợ lý Mun AI\nĐồng bộ Firebase Cloud")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                }

                // Auth Card
                VStack(spacing: 18) {
                    // Mode Switcher
                    HStack(spacing: 4) {
                        modeTabButton(title: "Đăng Nhập", isSelected: isLoginMode) {
                            withAnimation {
                                isLoginMode = true
                                errorMessage = nil
                            }
                        }
                        modeTabButton(title: "Đăng Ký", isSelected: !isLoginMode) {
                            withAnimation {
                                isLoginMode = false
                                errorMessage = nil
                            }
                        }
                    }
                    .padding(4)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.08)))

                    // Form Fields
                    VStack(alignment: .leading, spacing: 14) {
                        // Email / Username
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email hoặc Tên đăng nhập:")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.8))

                            HStack(spacing: 10) {
                                Image(systemName: "person.fill")
                                    .foregroundStyle(LiquidGlassTheme.secondaryAccent)
                                TextField("Ví dụ: hungdaden hoặc email", text: $emailOrUsername)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white)
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.08)))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.15), lineWidth: 1))
                        }

                        // Password
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Mật khẩu:")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.8))

                            HStack(spacing: 10) {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(LiquidGlassTheme.primaryAccent)
                                SecureField("Tối thiểu 6 ký tự", text: $password)
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white)
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.08)))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.15), lineWidth: 1))
                        }

                        // Confirm Password (if registering)
                        if !isLoginMode {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Nhập lại mật khẩu:")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.8))

                                HStack(spacing: 10) {
                                    Image(systemName: "lock.rotation")
                                        .foregroundStyle(LiquidGlassTheme.primaryAccent)
                                    SecureField("Xác nhận mật khẩu", text: $confirmPassword)
                                        .font(.system(size: 14))
                                        .foregroundStyle(.white)
                                }
                                .padding(12)
                                .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.08)))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.15), lineWidth: 1))
                            }
                        }
                    }

                    // Error Message
                    if let error = errorMessage {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(LiquidGlassTheme.roseAccent)
                            Text(error)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(LiquidGlassTheme.roseAccent)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Action Button
                    Button {
                        handleAuth()
                    } label: {
                        HStack(spacing: 8) {
                            if userVM.authService.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: isLoginMode ? "arrow.right.circle.fill" : "person.badge.plus")
                                Text(isLoginMode ? "Đăng Nhập Ngay" : "Tạo Tài Khoản")
                                    .font(.system(size: 15, weight: .bold))
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 16).fill(LiquidGlassTheme.primaryButtonGradient))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.3), lineWidth: 1))
                        .shadow(color: LiquidGlassTheme.primaryAccent.opacity(0.4), radius: 10, x: 0, y: 4)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(userVM.authService.isLoading)
                }
                .liquidGlassCard(cornerRadius: 24, padding: 20)

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 20)
        }
        .liquidGlassBackground()
    }

    private func modeTabButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 10).fill(LiquidGlassTheme.primaryButtonGradient)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private func handleAuth() {
        let cleanInput = emailOrUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanInput.isEmpty, !password.isEmpty else {
            errorMessage = "Vui lòng nhập đầy đủ tài khoản và mật khẩu."
            return
        }

        if !isLoginMode && password != confirmPassword {
            errorMessage = "Mật khẩu xác nhận không khớp."
            return
        }

        errorMessage = nil

        Task {
            if isLoginMode {
                let err = await userVM.authService.signIn(emailOrUsername: cleanInput, password: password)
                if let err {
                    self.errorMessage = err
                } else {
                    userVM.showNotification(title: "Thành công", message: "Đăng nhập thành công!", type: .success)
                }
            } else {
                let err = await userVM.authService.signUp(emailOrUsername: cleanInput, password: password)
                if let err {
                    self.errorMessage = err
                } else {
                    userVM.showNotification(title: "Chào mừng", message: "Tạo tài khoản thành công!", type: .success)
                }
            }
        }
    }
}
