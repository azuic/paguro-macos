import Foundation

enum PaguroPaths {
    static let appSupportDirectory: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent("Paguro", isDirectory: true)
    }()

    static let bridgeDirectory = appSupportDirectory.appendingPathComponent("bridges", isDirectory: true)
    static let claudeStatusSnapshot = bridgeDirectory.appendingPathComponent("claude-statusline-latest.json")

    static func ensureBridgeDirectoryExists() throws {
        try FileManager.default.createDirectory(at: bridgeDirectory, withIntermediateDirectories: true)
    }
}
