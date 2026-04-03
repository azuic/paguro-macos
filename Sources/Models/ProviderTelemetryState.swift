import Foundation

struct ProviderTelemetryState: Codable, Equatable {
    var claude: ClaudeTelemetryState
    var openAI: OpenAITelemetryState

    init(
        claude: ClaudeTelemetryState = ClaudeTelemetryState(),
        openAI: OpenAITelemetryState = OpenAITelemetryState()
    ) {
        self.claude = claude
        self.openAI = openAI
    }
}

struct ClaudeTelemetryState: Codable, Equatable {
    var sessions: [String: ClaudeSessionCursor]
    var lastSnapshotAt: Date?
    var lastSessionID: String?
    var lastSessionName: String?
    var lastModelDisplayName: String?
    var lastCurrentInputTokens: Int?
    var lastCurrentOutputTokens: Int?
    var lastTotalInputTokens: Int?
    var lastTotalOutputTokens: Int?
    var lastEnergyGain: Int?
    var lastUsageAppliedAt: Date?

    init(
        sessions: [String: ClaudeSessionCursor] = [:],
        lastSnapshotAt: Date? = nil,
        lastSessionID: String? = nil,
        lastSessionName: String? = nil,
        lastModelDisplayName: String? = nil,
        lastCurrentInputTokens: Int? = nil,
        lastCurrentOutputTokens: Int? = nil,
        lastTotalInputTokens: Int? = nil,
        lastTotalOutputTokens: Int? = nil,
        lastEnergyGain: Int? = nil,
        lastUsageAppliedAt: Date? = nil
    ) {
        self.sessions = sessions
        self.lastSnapshotAt = lastSnapshotAt
        self.lastSessionID = lastSessionID
        self.lastSessionName = lastSessionName
        self.lastModelDisplayName = lastModelDisplayName
        self.lastCurrentInputTokens = lastCurrentInputTokens
        self.lastCurrentOutputTokens = lastCurrentOutputTokens
        self.lastTotalInputTokens = lastTotalInputTokens
        self.lastTotalOutputTokens = lastTotalOutputTokens
        self.lastEnergyGain = lastEnergyGain
        self.lastUsageAppliedAt = lastUsageAppliedAt
    }

    var isActive: Bool {
        guard let lastSnapshotAt else {
            return false
        }

        return Date().timeIntervalSince(lastSnapshotAt) < 20
    }

    var statusLine: String {
        isActive ? "Live" : "Idle"
    }
}

struct ClaudeSessionCursor: Codable, Equatable {
    var totalInputTokens: Int
    var totalOutputTokens: Int
}

struct OpenAITelemetryState: Codable, Equatable {
    var lastUsageAppliedAt: Date?

    init(lastUsageAppliedAt: Date? = nil) {
        self.lastUsageAppliedAt = lastUsageAppliedAt
    }
}
