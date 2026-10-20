import SwiftUI

public struct AddUserSheet: View {
    @ObservedObject public var userVM: UserViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var targetScore: Int = 750
    @State private var dateOfBirth: Date = Calendar.current.date(from: DateComponents(year: 2004, month: 1, day: 1)) ?? Date()
    @State private var isFourSkills: Bool = false

    public var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)

                Text("Tạo Hồ Sơ Học Viên")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)

                Text("Thêm hồ sơ để theo dõi tiến trình và thi đua cùng bạn bè.")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.65))
            }

            VStack(alignment: .leading, spacing: 14) {
                // Name
                VStack(alignment: .leading, spacing: 6) {
                    Text("Họ và tên học viên:")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.8))

                    TextField("Ví dụ: Nguyễn Văn A", text: $name)
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.08)))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.15), lineWidth: 1))
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

            // Submit Button
            LiquidGlassButton(title: "Tạo Hồ Sơ", icon: "person.badge.plus.fill") {
                let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                userVM.addUser(
                    name: trimmed,
                    targetScore: targetScore,
                    dateOfBirth: dateOfBirth,
                    isFourSkills: isFourSkills
                )
                dismiss()
            }
            .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            Spacer().frame(height: 10)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .background(Color(hex: 0x0E1424).ignoresSafeArea())
        .presentationDetents([.height(480)])
    }
}
