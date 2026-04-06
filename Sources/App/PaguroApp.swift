import SwiftUI

@main
struct PaguroApp: App {
    @NSApplicationDelegateAdaptor(PaguroAppDelegate.self) private var appDelegate
    @StateObject private var store = PaguroStore.shared

    var body: some Scene {
        MenuBarExtra {
            PaguroWidgetView()
                .environmentObject(store)
                .frame(width: 432)
        } label: {
            PaguroMenuBarLabelView(pet: store.activePet)
        }
        .menuBarExtraStyle(.window)
    }
}
