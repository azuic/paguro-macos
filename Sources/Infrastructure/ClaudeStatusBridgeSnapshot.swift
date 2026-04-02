import Foundation

struct ClaudeStatusBridgeSnapshot: Decodable {
    let sessionID: String
    let sessionName: String?
    let model: Model
    let contextWindow: ContextWindow

    enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case sessionName = "session_name"
        case model
        case contextWindow = "context_window"
    }

    struct Model: Decodable {
        let displayName: String

        enum CodingKeys: String, CodingKey {
            case displayName = "display_name"
        }
    }

    struct ContextWindow: Decodable {
        let totalInputTokens: Int
        let totalOutputTokens: Int
        let usedPercentage: Double?
        let currentUsage: CurrentUsage?

        enum CodingKeys: String, CodingKey {
            case totalInputTokens = "total_input_tokens"
            case totalOutputTokens = "total_output_tokens"
            case usedPercentage = "used_percentage"
            case currentUsage = "current_usage"
        }
    }

    struct CurrentUsage: Decodable {
        let inputTokens: Int?
        let outputTokens: Int?
        let cacheCreationInputTokens: Int?
        let cacheReadInputTokens: Int?

        enum CodingKeys: String, CodingKey {
            case inputTokens = "input_tokens"
            case outputTokens = "output_tokens"
            case cacheCreationInputTokens = "cache_creation_input_tokens"
            case cacheReadInputTokens = "cache_read_input_tokens"
        }
    }
}
