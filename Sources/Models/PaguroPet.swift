import Foundation

enum ProviderKind: String, Codable, CaseIterable, Identifiable {
    case claude
    case openAI

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .claude:
            return "Claude"
        case .openAI:
            return "OpenAI"
        }
    }

    var accentLabel: String {
        switch self {
        case .claude:
            return "CC"
        case .openAI:
            return "OA"
        }
    }
}

enum PetStage: String, Codable {
    case hatchling
    case adolescent
    case adult

    var displayName: String {
        rawValue.capitalized
    }
}

enum ShellVariant: String, Codable, CaseIterable {
    case sand
    case sunset
    case lagoon

    var displayName: String {
        switch self {
        case .sand:
            return "Sand Shell"
        case .sunset:
            return "Sunset Shell"
        case .lagoon:
            return "Lagoon Shell"
        }
    }

    var price: Int {
        switch self {
        case .sand:
            return 90
        case .sunset:
            return 160
        case .lagoon:
            return 220
        }
    }

    var hueRotation: Double {
        switch self {
        case .sand:
            return 0
        case .sunset:
            return 310
        case .lagoon:
            return 180
        }
    }

    var next: ShellVariant {
        let all = ShellVariant.allCases

        guard let current = all.firstIndex(of: self) else {
            return self
        }

        return all[(current + 1) % all.count]
    }
}

enum PetMood: String {
    case sleepy
    case hungry
    case calm
    case lively
    case charged

    var displayName: String {
        switch self {
        case .sleepy:
            return "Sleepy"
        case .hungry:
            return "Hungry"
        case .calm:
            return "Calm"
        case .lively:
            return "Lively"
        case .charged:
            return "Charged"
        }
    }
}

struct PaguroPet: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var provider: ProviderKind
    var name: String
    var energy: Int
    var fullness: Int
    var growth: Int
    var stage: PetStage
    var shell: ShellVariant
    var bodyHue: Double
    var lastUsagePulseAt: Date?

    var mood: PetMood {
        if lastUsagePulseAt != nil {
            return .charged
        }

        if fullness < 26 {
            return .hungry
        }

        if energy < 150 {
            return .sleepy
        }

        if growth > 70 {
            return .lively
        }

        return .calm
    }

    var weightText: String {
        "\(9 + growth / 6)g"
    }

    var shellProgressText: String {
        "\(growth)%"
    }
}
