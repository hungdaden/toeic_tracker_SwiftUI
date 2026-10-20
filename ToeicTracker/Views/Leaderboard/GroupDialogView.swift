import SwiftUI

public struct GroupDialogView: View {
    @ObservedObject public var userVM: UserViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var groupCodeInput: String = ""
    @State private var groupNameInput: String = ""
    @State private var isCreatingGroup: Bool = false

    public var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)

                Text("Quản Lý Nhóm Học Tập")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)

                Text("Cùng nhau thi đua điểm số và giữ chuỗi học tập đều đặn!")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.65))
                    .multilineTextAlignment(.center)
            }

            // Mode Selector
            Picker("Chế độ", selection: $isCreatingGroup) {
                Text("Tham gia nhóm").tag(false)
                Text("Tạo nhóm mới").tag(true)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 8)

            if !isCreatingGroup {
                // Join Group by Code
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mã nhóm (5 ký tự):")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.8))

                    TextField("Ví dụ: TOEIC", text: $groupCodeInput)
                        .textInputAutocapitalization(.characters)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.08)))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(LiquidGlassTheme.primaryAccent.opacity(0.4), lineWidth: 1))
                }
            } else {
                // Create Group
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tên nhóm học tập:")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.8))

                    TextField("Ví dụ: Đội 900+ Bứt Phá", text: $groupNameInput)
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.08)))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(LiquidGlassTheme.emeraldAccent.opacity(0.4), lineWidth: 1))
                }
            }

            // Submit Button
            LiquidGlassButton(
                title: isCreatingGroup ? "Tạo Nhóm Mới" : "Tham Gia Nhóm",
                icon: isCreatingGroup ? "plus.circle.fill" : "person.3.fill",
                gradient: isCreatingGroup ? LiquidGlassTheme.emeraldGradient : LiquidGlassTheme.primaryButtonGradient
            ) {
                if isCreatingGroup {
                    if let user = userVM.currentUser {
                        var updated = user
                        updated.groupId = "GP" + String(Int.random(in: 100...999))
                        updated.groupRole = "leader"
                        userVM.updateUser(updated)
                        userVM.showNotification(title: "Thành công", message: "Đã tạo nhóm: \(groupNameInput.isEmpty ? "Nhóm TOEIC" : groupNameInput)!", type: .success)
                    }
                } else {
                    if let user = userVM.currentUser {
                        var updated = user
                        updated.groupId = groupCodeInput.isEmpty ? "TOEIC" : groupCodeInput.uppercased()
                        updated.groupRole = "member"
                        userVM.updateUser(updated)
                        userVM.showNotification(title: "Thành công", message: "Đã tham gia nhóm \(updated.groupId ?? "")!", type: .success)
                    }
                }
                dismiss()
            }

            Spacer().frame(height: 10)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .background(Color(hex: 0x0E1424).ignoresSafeArea())
        .presentationDetents([.height(340)])
    }
}
