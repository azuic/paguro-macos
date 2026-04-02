import Darwin
import Foundation

final class ClaudeStatusBridgeMonitor {
    private let snapshotURL: URL
    private let directoryURL: URL
    private let queue = DispatchQueue(label: "com.azuic.paguro.claude-bridge")
    private let onSnapshot: @Sendable (ClaudeStatusBridgeSnapshot, Date) -> Void

    private var source: DispatchSourceFileSystemObject?
    private var directoryDescriptor: CInt = -1
    private var lastSnapshotData = Data()

    init(
        snapshotURL: URL = PaguroPaths.claudeStatusSnapshot,
        onSnapshot: @escaping @Sendable (ClaudeStatusBridgeSnapshot, Date) -> Void
    ) {
        self.snapshotURL = snapshotURL
        directoryURL = snapshotURL.deletingLastPathComponent()
        self.onSnapshot = onSnapshot
    }

    deinit {
        stop()
    }

    func start() {
        queue.async { [weak self] in
            self?.startOnQueue()
        }
    }

    func refreshNow() {
        queue.async { [weak self] in
            self?.processLatestSnapshot(force: true)
        }
    }

    func stop() {
        queue.sync {
            source?.cancel()
            source = nil
            directoryDescriptor = -1
        }
    }

    private func startOnQueue() {
        do {
            try PaguroPaths.ensureBridgeDirectoryExists()
        } catch {
            return
        }

        processLatestSnapshot(force: true)

        guard source == nil else {
            return
        }

        directoryDescriptor = open(directoryURL.path, O_EVTONLY)
        guard directoryDescriptor >= 0 else {
            return
        }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: directoryDescriptor,
            eventMask: [.write, .rename, .delete, .attrib, .extend],
            queue: queue
        )

        source.setEventHandler { [weak self] in
            self?.processLatestSnapshot(force: false)
        }

        source.setCancelHandler { [directoryDescriptor] in
            if directoryDescriptor >= 0 {
                close(directoryDescriptor)
            }
        }

        self.source = source
        source.resume()
    }

    private func processLatestSnapshot(force: Bool) {
        guard
            let data = try? Data(contentsOf: snapshotURL),
            !data.isEmpty
        else {
            return
        }

        if !force && data == lastSnapshotData {
            return
        }

        guard let snapshot = try? JSONDecoder().decode(ClaudeStatusBridgeSnapshot.self, from: data) else {
            return
        }

        lastSnapshotData = data
        let modifiedAt = (try? snapshotURL.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date()
        onSnapshot(snapshot, modifiedAt)
    }
}
