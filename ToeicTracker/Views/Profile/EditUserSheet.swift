import SwiftUI

public struct EditUserSheet: View {
    public let user: UserModel
    @ObservedObject public var userVM: UserViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var targetScore: Int = 750
    @State private var dateOfBirth: Date = Date()
    @State private var isFourSkills: Bool = false

    public var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)

                Text("Chỉnh Sửa Hồ Sơ")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 14) {
                // Name
                VStack(alignment: .leading, spacing: 6) {
                    Text("Họ và tên:")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.8))

                    TextField("Tên học viên", text: $name)
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.08)))
                }

                // Target Score
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Điểm mục tiêu:")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.8))
                        Spacer()
                        Text("\(targetScore) điểm")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(LiquidGlassTheme.scoreTotal)
                    }

                    Stepper("", value: $targetScore, in: 200...990, step: 25)
                        .labelsHidden()
                        .colorScheme(.dark)
                }

                // Date of Birth
                DatePicker("Ngày sinh", selection: $dateOfBirth, displayedComponents: .date)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
                    .colorScheme(.dark)

                // 4 Skills toggle
                Toggle("Học 4 kỹ năng (Nghe, Đọc, Nói, Viết)", isOn: $isFourSkills)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
                    .tint(LiquidGlassTheme.primaryAccent)
            }
            .liquidGlassCard(cornerRadius: 20, padding: 16)

            // Save Button
            LiquidGlassButton(title: "Lưu Thay Đổi", icon: "checkmark") {
                let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                var updated = user
                updated.name = trimmed
                updated.targetScore = targetScore
                updated.dateOfBirth = dateOfBirth
                updated.isFourSkills = isFourSkills
                userVM.updateUser(updated)
                dismiss()
            }

            Spacer().frame(height: 10)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .background(Color(hex: 0x0E1424).ignoresSafeArea())
        .presentationDetents([.height(460)])
        .onAppear {
            name = user.name
            targetScore = user.targetScore
            dateOfBirth = user.dateOfBirth
            isFourSkills = user.isFourSkills
        }
    }
}
