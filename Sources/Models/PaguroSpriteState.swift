import Foundation

enum PaguroSpritePose: String {
    case idle = "idle"
    case walkA = "walk_a"
    case walkB = "walk_b"

    var assetSuffix: String {
        rawValue
    }
}

enum PaguroSpriteDirection {
    case left
    case right
}

enum PaguroSpriteExpression: String {
    case neutral = "mouth_neutral"
    case smile = "mouth_smile"
    case sleepy = "mouth_sleepy"

    var assetName: String {
        rawValue
    }

    static func from(mood: PetMood) -> PaguroSpriteExpression {
        switch mood {
        case .charged, .lively:
            return .smile
        case .sleepy:
            return .sleepy
        case .hungry, .calm:
            return .neutral
        }
    }
}
