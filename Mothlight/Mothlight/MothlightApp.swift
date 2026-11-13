import SwiftUI

@main
struct MothlightApp: App {
    @StateObject private var purchaseManager = PurchaseManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(purchaseManager)
                .preferredColorScheme(.dark)
        }
    }
}
