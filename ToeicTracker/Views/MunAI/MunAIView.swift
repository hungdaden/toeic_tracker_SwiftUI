import SwiftUI

public struct MunAIView: View {
    @ObservedObject public var munAIVM: MunAIViewModel
    @ObservedObject public var userVM: UserViewModel

    @State private var inputText: String = ""
    @FocusState private var isInputFocused: Bool

    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            headerBar

            // Chat Messages Scroll
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(munAIVM.currentSession.messages) { msg in
                            ChatBubbleView(message: msg)
                                .id(msg.id)
                        }

                        if munAIVM.isThinking {
                            thinkingIndicator
                                .id("thinking_indicator")
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                }
                .onChange(of: munAIVM.currentSession.messages.count) { _ in
                    if let last = munAIVM.currentSession.messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: munAIVM.isThinking) { thinking in
                    if thinking {
                        withAnimation {
                            proxy.scrollTo("thinking_indicator", anchor: .bottom)
                        }
                    }
                }
            }

            // Quick Suggestions Chips (if only 1 or 2 messages)
            if munAIVM.currentSession.messages.count <= 2 {
                suggestionsSection
            }

            // Bottom Input Bar
            bottomInputBar
                .padding(.bottom, 90) // Pad for floating tab bar
        }
        .liquidGlassBackground()
        .sheet(isPresented: $munAIVM.showDrawer) {
            ChatSessionDrawer(munAIVM: munAIVM)
        }
    }

    // MARK: - Header Bar
    private var headerBar: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LiquidGlassTheme.purpleGradient)
                    .frame(width: 42, height: 42)
                    .shadow(color: LiquidGlassTheme.purpleAccent.opacity(0.4), radius: 8)

                Text("🐱")
                    .font(.system(size: 20))
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("Mun AI")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Online")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(LiquidGlassTheme.scoreTotal)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(LiquidGlassTheme.scoreTotal.opacity(0.18)))
                }

                Text("Cố vấn TOEIC Gemini thông minh")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()

            Button {
                munAIVM.showDrawer = true
            } label: {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(Color.white.opacity(0.08)))
                    .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(hex: 0x0E1424).opacity(0.9))
    }

    // MARK: - Suggestions Section
    private var suggestionsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(munAIVM.suggestions, id: \.self) { sug in
                    Button {
                        inputText = sug
                        Task {
                            await munAIVM.sendMessage(text: sug, currentUser: userVM.currentUser)
                        }
                    } label: {
                        Text(sug)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(LiquidGlassTheme.purpleAccent.opacity(0.15)))
                            .overlay(Capsule().stroke(LiquidGlassTheme.purpleAccent.opacity(0.35), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Thinking Indicator
    private var thinkingIndicator: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(LiquidGlassTheme.purpleGradient)
                    .frame(width: 32, height: 32)
                Text("🐱")
                    .font(.system(size: 16))
            }

            HStack(spacing: 4) {
                Text("Mun AI đang suy nghĩ...")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))

                ProgressView()
                    .tint(LiquidGlassTheme.purpleAccent)
                    .scaleEffect(0.8)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.06)))

            Spacer()
        }
    }

    // MARK: - Bottom Input Bar
    private var bottomInputBar: some View {
        HStack(spacing: 10) {
            TextField("Hỏi Mun AI về đề thi, từ vựng, mẹo...", text: $inputText)
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .focused($isInputFocused)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 22).fill(Color.white.opacity(0.08)))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.18), lineWidth: 1))

            Button {
                let msg = inputText
                inputText = ""
                Task {
                    await munAIVM.sendMessage(text: msg, currentUser: userVM.currentUser)
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(
                        inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? Color.white.opacity(0.3)
                        : LiquidGlassTheme.purpleAccent
                    )
            }
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || munAIVM.isThinking)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(hex: 0x090D16).opacity(0.95))
    }
}
