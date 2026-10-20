import SwiftUI

@main
struct ToeicTrackerApp: App {
    @StateObject private var userVM = UserViewModel()
    @StateObject private var examVM = ExamViewModel()
    @StateObject private var munAIVM = MunAIViewModel()

    var body: some Scene {
        WindowGroup {
            MainView(
                userVM: userVM,
                examVM: examVM,
                munAIVM: munAIVM
            )
        }
    }
}
