import SwiftUI

public struct LearningPathView: View {
    @ObservedObject public var userVM: UserViewModel
    @Environment(\.dismiss) private var dismiss

    private var currentUser: UserModel? {
        userVM.currentUser
    }

    private var isFourSkills: Bool {
        currentUser?.isFourSkills ?? false
    }

    private var currentTotal: Int {
        currentUser?.latestScore?.calculateTotal(isFourSkills: isFourSkills) ?? 500
    }

    private var levelInfo: (title: String, desc: String, color: Color, advice: [String]) {
        if currentTotal < 450 {
            return (
                title: "Mức Cơ Bản (< 450 điểm)",
                desc: "Xây dựng nền móng vững chắc về từ vựng trọng tâm và ngữ pháp cơ bản.",
                color: LiquidGlassTheme.amberAccent,
                advice: [
                    "Học thuộc 600 từ vựng TOEIC căn bản (chủ đề văn phòng, du lịch, hợp đồng).",
                    "Nắm chắc các thì cơ bản, đại từ, mệnh đề quan hệ và bị động.",
                    "Luyện nghe chép chính tả Part 1 và Part 2 để tạo phản xạ âm điệu tiếng Anh.",
                    "Không nên làm đề full ngay, hãy chia nhỏ luyện từng Part 10-15 câu mỗi ngày."
                ]
            )
        } else if currentTotal < 650 {
            return (
                title: "Mức Trung Cấp (450 - 650 điểm)",
                desc: "Mở rộng từ vựng chuyên sâu và tối ưu hóa thời gian xử lý câu hỏi ngắn.",
                color: LiquidGlassTheme.scoreListening,
                advice: [
                    "Hoàn thiện ngữ pháp nâng cao Part 5: liên từ, giới từ, câu điều kiện, đảo ngữ.",
                    "Luyện kỹ năng nghe hội thoại ngắn Part 3: đọc trước 3 câu hỏi trước khi audio phát.",
                    "Học cách nhận biết các bẫy quen thuộc của ETS trong Part 2 (lặp từ, đồng âm).",
                    "Rèn luyện thói quen giải Part 5 & 6 tối đa 30-40 giây cho mỗi câu."
                ]
            )
        } else if currentTotal < 800 {
            return (
                title: "Mức Khá Giỏi (650 - 800 điểm)",
                desc: "Nâng cao phản xạ tốc độ và khả năng đọc hiểu văn bản dài Part 7.",
                color: LiquidGlassTheme.scoreTotal,
                advice: [
                    "Tập trung rèn luyện Part 4: nghe bài nói dài (talks) với khả năng ghi nhớ chi tiết.",
                    "Áp dụng triệt để kỹ thuật Scanning & Skimming cho Part 7 đoạn đơn và đoạn kép.",
                    "Trau dồi các cặp từ đồng nghĩa (Paraphrasing) xuất hiện dày đặc trong đáp án đúng.",
                    "Làm bài thi thử 120 phút đầy đủ mỗi tuần để căn chỉnh nhịp độ đồng hồ bấm giờ."
                ]
            )
        } else {
            return (
                title: "Mức Xuất Sắc (> 800 điểm)",
                desc: "Hoàn thiện chiến thuật tuyệt đối để chinh phục mốc 900+ và 990 tối đa.",
                color: LiquidGlassTheme.purpleAccent,
                advice: [
                    "Rút ngắn thời gian làm bài: hoàn thành Part 5 & 6 trong vòng 15-18 phút.",
                    "Phân tích thật kỹ các câu sai trong Part 7 đoạn ba (Triple Passages).",
                    "Luyện các câu hỏi suy luận sâu (What is implied/inferred about...?).",
                    "Giữ vững chuỗi Streak hàng ngày để duy trì độ nhạy bén của tai nghe và mắt đọc."
                ]
            )
        }
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 40, height: 5)
                        .padding(.top, 8)

                    Text("Lộ Trình Học Cá Nhân Hóa")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Lộ trình được Mun AI điều chỉnh tối ưu theo kết quả thi của bạn.")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.65))
                }

                // Current Level Card
                VStack(spacing: 12) {
                    HStack {
                        Text(levelInfo.title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(levelInfo.color)

                        Spacer()

                        Text("Hiện tại: \(currentTotal)đ")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    Text(levelInfo.desc)
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.85))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .liquidGlassCard(cornerRadius: 20, padding: 16)

                // Recommendations list
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 8) {
                        Image(systemName: "checklist")
                            .foregroundStyle(LiquidGlassTheme.scoreTotal)
                        Text("Trọng Tâm Ôn Luyện Cần Làm")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    ForEach(Array(levelInfo.advice.enumerated()), id: \.offset) { idx, item in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(idx + 1)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(levelInfo.color)
                                .frame(width: 24, height: 24)
                                .background(Circle().fill(levelInfo.color.opacity(0.18)))

                            Text(item)
                                .font(.system(size: 13))
                                .foregroundStyle(.white.opacity(0.9))
                                .lineSpacing(3)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .liquidGlassCard(cornerRadius: 22, padding: 18)

                // Part-by-Part Strategy
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "target")
                            .foregroundStyle(LiquidGlassTheme.primaryAccent)
                        Text("Mục Tiêu Tốc Độ Các Part")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    strategyRow(part: "Part 1 & 2 (31 câu)", time: "Audio chuẩn ETS", tip: "Khóa chặt bẫy lặp âm và câu trả lời gián tiếp.")
                    strategyRow(part: "Part 3 & 4 (69 câu)", time: "Audio chuẩn ETS", tip: "Đọc lướt câu hỏi trước khi audio vang lên.")
                    strategyRow(part: "Part 5 (30 câu)", time: "~10 phút", tip: "Tập trung từ loại và cấu trúc ngữ pháp nhanh.")
                    strategyRow(part: "Part 6 (16 câu)", time: "~8 phút", tip: "Chọn câu phù hợp ngữ cảnh đoạn văn.")
                    strategyRow(part: "Part 7 (54 câu)", time: "~55 phút", tip: "Scanning tìm từ khóa, tránh đọc lan man.")
                }
                .liquidGlassCard(cornerRadius: 22, padding: 18)

                // Close Button
                LiquidGlassButton(title: "Đã Hiểu & Bắt Đầu Học", icon: "checkmark") {
                    dismiss()
                }

                Spacer().frame(height: 20)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(hex: 0x090D16).ignoresSafeArea())
    }

    private func strategyRow(part: String, time: String, tip: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(part)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Text(time)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(LiquidGlassTheme.secondaryAccent)
            }

            Text(tip)
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.65))
        }
        .padding(.vertical, 4)
    }
}
