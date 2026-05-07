import SwiftUI

@main
struct LingJuApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootTabView(appState: appState)
        }
    }
}
