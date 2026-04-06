import AppKit

@MainActor
final class PaguroAppDelegate: NSObject, NSApplicationDelegate {
    private var desktopPetWindowController: PaguroDesktopPetWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let controller = PaguroDesktopPetWindowController(store: PaguroStore.shared)
        desktopPetWindowController = controller
        controller.start()
    }
}
