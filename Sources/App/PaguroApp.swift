import SwiftUI

@main
struct PaguroApp: App {
    @StateObject private var store = PaguroStore()

    var body: some Scene {
        MenuBarExtra {
            PaguroWidgetView()
                .environmentObject(store)
                .frame(width: 532)
        } label: {
            PaguroMenuBarLabelView(pet: store.activePet)
        }
        .menuBarExtraStyle(.window)
    }
}
