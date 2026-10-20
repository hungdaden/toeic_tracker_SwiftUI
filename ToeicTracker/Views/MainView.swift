import SwiftUI

public struct MainView: View {
    @ObservedObject public var userVM: UserViewModel
    @ObservedObject public var examVM: ExamViewModel
    @ObservedObject public var munAIVM: MunAIViewModel

    @State private var selectedTab: AppTab = .home

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content Pages
            Group {
                switch selectedTab {
                case .home:
                    HomeView(userVM: userVM)
                case .exams:
                    ExamListView(examVM: examVM, userVM: userVM)
                case .munAI:
                    MunAIView(munAIVM: munAIVM, userVM: userVM)
                case .leaderboard:
                    LeaderboardView(userVM: userVM)
                case .profile:
                    ProfileView(userVM: userVM)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Floating Navigation Tab Bar
            FloatingTabBar(selectedTab: $selectedTab)

            // Confetti Overlay when target is hit
            if userVM.showAimHitConfetti {
                ConfettiView(isPresented: $userVM.showAimHitConfetti)
                    .ignoresSafeArea()
            }

            // Dynamic Island Notification Banner Overlay
            if let notif = userVM.activeNotification {
                VStack {
                    DynamicIslandNotificationBanner(notification: notif) {
                        withAnimation {
                            userVM.activeNotification = nil
                        }
                    }
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(100)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            munAIVM.loadUserChatHistory(user: userVM.currentUser)
        }
        .onChange(of: userVM.currentUserId) { _ in
            munAIVM.loadUserChatHistory(user: userVM.currentUser)
        }
    }
}
