import AppKit
import Combine
import SwiftUI

@MainActor
final class PaguroDesktopPetWindowController: NSObject {
    private let store: PaguroStore
    private let window: PaguroDesktopPetPanel
    private var cancellables = Set<AnyCancellable>()
    private var hasPositionedWindow = false

    init(store: PaguroStore) {
        self.store = store
        let hostingController = NSHostingController(rootView: PaguroDesktopPetView().environmentObject(store))
        self.window = PaguroDesktopPetPanel(contentViewController: hostingController)

        super.init()

        configureWindow()
        bind()
    }

    func start() {
        syncVisibility(store.desktopPetEnabled)
    }

    private func configureWindow() {
        window.setContentSize(NSSize(width: 248, height: 248))
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        window.ignoresMouseEvents = true
        window.hidesOnDeactivate = false
        window.isMovableByWindowBackground = false
        window.animationBehavior = .none
    }

    private func bind() {
        store.$desktopPetEnabled
            .removeDuplicates()
            .sink { [weak self] isEnabled in
                self?.syncVisibility(isEnabled)
            }
            .store(in: &cancellables)
    }

    private func syncVisibility(_ isEnabled: Bool) {
        guard isEnabled else {
            window.orderOut(nil)
            return
        }

        positionWindowIfNeeded()
        window.orderFrontRegardless()
    }

    private func positionWindowIfNeeded() {
        guard !hasPositionedWindow else {
            return
        }

        guard let screen = NSScreen.main ?? NSScreen.screens.first else {
            return
        }

        let visibleFrame = screen.visibleFrame
        let size = window.frame.size
        let origin = NSPoint(
            x: visibleFrame.maxX - size.width - 20,
            y: visibleFrame.minY + 28
        )

        window.setFrameOrigin(origin)
        hasPositionedWindow = true
    }
}

private final class PaguroDesktopPetPanel: NSPanel {
    init(contentViewController: NSViewController) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 248, height: 248),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        self.contentViewController = contentViewController
        isFloatingPanel = true
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
