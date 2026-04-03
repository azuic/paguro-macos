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

    static func from(growth: Int) -> PetStage {
        switch growth {
        case ..<34:
            return .hatchling
        case ..<72:
            return .adolescent
        default:
            return .adult
        }
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

enum PetPattern: String, Codable, CaseIterable {
    case plain
    case speckles
    case stripes

    var displayName: String {
        switch self {
        case .plain:
            return "Plain"
        case .speckles:
            return "Speckles"
        case .stripes:
            return "Stripes"
        }
    }
}

enum FoodKind: String, Codable, CaseIterable, Identifiable {
    case berryBits
    case kelpCrunch
    case sunMorsel

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .berryBits:
            return "Berry Bits"
        case .kelpCrunch:
            return "Kelp Crunch"
        case .sunMorsel:
            return "Sun Morsel"
        }
    }

    var shortDetail: String {
        switch self {
        case .berryBits:
            return "Sweet / Speckles"
        case .kelpCrunch:
            return "Fresh / Stripes"
        case .sunMorsel:
            return "Warm / Glow"
        }
    }

    var price: Int {
        switch self {
        case .berryBits:
            return 28
        case .kelpCrunch:
            return 42
        case .sunMorsel:
            return 58
        }
    }

    var fullnessGain: Int {
        switch self {
        case .berryBits:
            return 16
        case .kelpCrunch:
            return 14
        case .sunMorsel:
            return 12
        }
    }

    var hueShift: Double {
        switch self {
        case .berryBits:
            return 12
        case .kelpCrunch:
            return 165
        case .sunMorsel:
            return 38
        }
    }

    var pattern: PetPattern {
        switch self {
        case .berryBits:
            return .speckles
        case .kelpCrunch:
            return .stripes
        case .sunMorsel:
            return .plain
        }
    }
}

struct PetInventory: Codable, Equatable {
    var berryBitsCount: Int
    var kelpCrunchCount: Int
    var sunMorselCount: Int
    var eggs: Int
    var ownedShells: [ShellVariant]

    init(
        berryBitsCount: Int = 0,
        kelpCrunchCount: Int = 0,
        sunMorselCount: Int = 0,
        eggs: Int = 0,
        ownedShells: [ShellVariant] = []
    ) {
        self.berryBitsCount = berryBitsCount
        self.kelpCrunchCount = kelpCrunchCount
        self.sunMorselCount = sunMorselCount
        self.eggs = eggs
        self.ownedShells = ownedShells
    }

    func count(for food: FoodKind) -> Int {
        switch food {
        case .berryBits:
            return berryBitsCount
        case .kelpCrunch:
            return kelpCrunchCount
        case .sunMorsel:
            return sunMorselCount
        }
    }

    mutating func addFood(_ food: FoodKind, amount: Int = 1) {
        switch food {
        case .berryBits:
            berryBitsCount += amount
        case .kelpCrunch:
            kelpCrunchCount += amount
        case .sunMorsel:
            sunMorselCount += amount
        }
    }

    mutating func consumeFood(_ food: FoodKind) -> Bool {
        switch food {
        case .berryBits where berryBitsCount > 0:
            berryBitsCount -= 1
            return true
        case .kelpCrunch where kelpCrunchCount > 0:
            kelpCrunchCount -= 1
            return true
        case .sunMorsel where sunMorselCount > 0:
            sunMorselCount -= 1
            return true
        default:
            return false
        }
    }

    mutating func addShell(_ shell: ShellVariant) {
        guard !ownedShells.contains(shell) else {
            return
        }

        ownedShells.append(shell)
    }

    mutating func addEgg() {
        eggs += 1
    }

    mutating func consumeEgg() -> Bool {
        guard eggs > 0 else {
            return false
        }

        eggs -= 1
        return true
    }

    static func starter(currentShell: ShellVariant) -> PetInventory {
        PetInventory(
            berryBitsCount: 1,
            kelpCrunchCount: 1,
            sunMorselCount: 0,
            eggs: 0,
            ownedShells: [currentShell]
        )
    }
}

struct PetSelectionState: Codable, Equatable {
    var claudePetID: UUID?
    var openAIPetID: UUID?

    func petID(for provider: ProviderKind) -> UUID? {
        switch provider {
        case .claude:
            return claudePetID
        case .openAI:
            return openAIPetID
        }
    }

    mutating func setPetID(_ id: UUID?, for provider: ProviderKind) {
        switch provider {
        case .claude:
            claudePetID = id
        case .openAI:
            openAIPetID = id
        }
    }
}

struct PaguroPet: Identifiable, Codable, Equatable {
    var id: UUID
    var provider: ProviderKind
    var name: String
    var energy: Int
    var fullness: Int
    var growth: Int
    var stage: PetStage
    var shell: ShellVariant
    var bodyHue: Double
    var pattern: PetPattern
    var inventory: PetInventory
    var lastUsagePulseAt: Date?

    init(
        id: UUID = UUID(),
        provider: ProviderKind,
        name: String,
        energy: Int,
        fullness: Int,
        growth: Int,
        stage: PetStage? = nil,
        shell: ShellVariant,
        bodyHue: Double,
        pattern: PetPattern = .plain,
        inventory: PetInventory? = nil,
        lastUsagePulseAt: Date? = nil
    ) {
        self.id = id
        self.provider = provider
        self.name = name
        self.energy = energy
        self.fullness = fullness
        self.growth = growth
        self.stage = stage ?? .from(growth: growth)
        self.shell = shell
        self.bodyHue = bodyHue
        self.pattern = pattern
        self.inventory = inventory ?? .starter(currentShell: shell)
        self.lastUsagePulseAt = lastUsagePulseAt
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case provider
        case name
        case energy
        case fullness
        case growth
        case stage
        case shell
        case bodyHue
        case pattern
        case inventory
        case lastUsagePulseAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let shell = try container.decode(ShellVariant.self, forKey: .shell)
        let growth = try container.decode(Int.self, forKey: .growth)

        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        provider = try container.decode(ProviderKind.self, forKey: .provider)
        name = try container.decode(String.self, forKey: .name)
        energy = try container.decode(Int.self, forKey: .energy)
        fullness = try container.decode(Int.self, forKey: .fullness)
        self.growth = growth
        stage = try container.decodeIfPresent(PetStage.self, forKey: .stage) ?? .from(growth: growth)
        self.shell = shell
        bodyHue = try container.decode(Double.self, forKey: .bodyHue)
        pattern = try container.decodeIfPresent(PetPattern.self, forKey: .pattern) ?? .plain
        inventory = try container.decodeIfPresent(PetInventory.self, forKey: .inventory) ?? .starter(currentShell: shell)
        lastUsagePulseAt = try container.decodeIfPresent(Date.self, forKey: .lastUsagePulseAt)
    }

    mutating func syncDerivedState() {
        fullness = min(100, max(0, fullness))
        growth = min(100, max(0, growth))
        bodyHue = bodyHue.truncatingRemainder(dividingBy: 360)
        stage = .from(growth: growth)
        inventory.addShell(shell)
    }

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
}

enum ShopItemKind: Hashable, Identifiable {
    case food(FoodKind)
    case shell(ShellVariant)
    case egg

    var id: String {
        switch self {
        case .food(let food):
            return "food-\(food.rawValue)"
        case .shell(let shell):
            return "shell-\(shell.rawValue)"
        case .egg:
            return "egg"
        }
    }
}

struct ShopListing: Identifiable {
    let kind: ShopItemKind
    let title: String
    let detail: String
    let badge: String
    let isAffordable: Bool
    let isOwned: Bool

    var id: String { kind.id }
}

enum BagItemKind: Hashable, Identifiable {
    case food(FoodKind)
    case shell(ShellVariant)
    case egg

    var id: String {
        switch self {
        case .food(let food):
            return "bag-food-\(food.rawValue)"
        case .shell(let shell):
            return "bag-shell-\(shell.rawValue)"
        case .egg:
            return "bag-egg"
        }
    }
}

struct BagListing: Identifiable {
    let kind: BagItemKind
    let title: String
    let detail: String
    let badge: String
    let isEquipped: Bool

    var id: String { kind.id }
}
