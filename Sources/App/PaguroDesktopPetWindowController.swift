import AppKit
import Combine
import SwiftUI

@MainActor
final class PaguroDesktopPetWindowController: NSObject {
    private let store: PaguroStore
    private let runtime: PaguroDesktopPetRuntime
    private let window: PaguroDesktopPetPanel
    private var cancellables = Set<AnyCancellable>()
    private var motionTimer: Timer?
    private var hasPositionedWindow = false
    private var horizontalVelocity: CGFloat = -2
    private var idleTicksRemaining = 22
    private var walkFrameTick = 0
    private var nextBlinkInTicks = 80
    private var blinkTicksRemaining = 0

    init(store: PaguroStore) {
        self.store = store
        self.runtime = PaguroDesktopPetRuntime()
        let hostingController = NSHostingController(
            rootView: PaguroDesktopPetView()
                .environmentObject(store)
                .environmentObject(runtime)
        )
        self.window = PaguroDesktopPetPanel(contentViewController: hostingController)

        super.init()

        configureWindow()
        bind()
    }

    func start() {
        syncExpression()
        startMotionLoop()
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
            runtime.pose = .idle
            window.orderOut(nil)
            return
        }

        positionWindowIfNeeded()
        window.orderFrontRegardless()
    }

    private func startMotionLoop() {
        motionTimer?.invalidate()

        let timer = Timer.scheduledTimer(withTimeInterval: 1 / 18, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
        timer.tolerance = 0.02
        motionTimer = timer
    }

    private func tick() {
        syncExpression()
        updateBlinkState()

        guard store.desktopPetEnabled else {
            runtime.pose = .idle
            return
        }

        guard let screen = window.screen ?? NSScreen.main ?? NSScreen.screens.first else {
            runtime.pose = .idle
            return
        }

        let visibleFrame = screen.visibleFrame
        let minX = visibleFrame.minX + 24
        let maxX = visibleFrame.maxX - window.frame.width - 24
        let baselineY = visibleFrame.minY + 6
        var origin = window.frame.origin
        origin.y = baselineY

        if idleTicksRemaining > 0 {
            idleTicksRemaining -= 1
            runtime.pose = .idle
            window.setFrameOrigin(origin)
            return
        }

        origin.x += horizontalVelocity
        if origin.x <= minX {
            origin.x = minX
            horizontalVelocity = abs(horizontalVelocity)
            idleTicksRemaining = 18
        } else if origin.x >= maxX {
            origin.x = maxX
            horizontalVelocity = -abs(horizontalVelocity)
            idleTicksRemaining = 18
        }

        runtime.direction = horizontalVelocity >= 0 ? .right : .left
        walkFrameTick = (walkFrameTick + 1) % 10
        runtime.pose = walkFrameTick < 5 ? .walkA : .walkB

        if Int.random(in: 0..<150) == 0 {
            idleTicksRemaining = Int.random(in: 16...36)
            runtime.pose = .idle
        }

        window.setFrameOrigin(origin)
    }

    private func syncExpression() {
        runtime.expression = PaguroSpriteExpression.from(mood: store.activePet.mood)
    }

    private func updateBlinkState() {
        if blinkTicksRemaining > 0 {
            blinkTicksRemaining -= 1
            runtime.isBlinking = true
            return
        }

        runtime.isBlinking = false
        nextBlinkInTicks -= 1

        if nextBlinkInTicks <= 0 {
            blinkTicksRemaining = 2
            nextBlinkInTicks = Int.random(in: 55...120)
        }
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
            y: visibleFrame.minY + 6
        )

        window.setFrameOrigin(origin)
        runtime.direction = .left
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
