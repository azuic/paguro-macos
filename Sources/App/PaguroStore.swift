import Foundation

@MainActor
final class PaguroStore: ObservableObject {
    static let shared = PaguroStore()

    @Published private(set) var pets: [PaguroPet]
    @Published private(set) var selection: PetSelectionState
    @Published private(set) var telemetry: ProviderTelemetryState
    @Published var desktopPetEnabled: Bool {
        didSet {
            save()
        }
    }
    @Published var selectedProvider: ProviderKind {
        didSet {
            save()
        }
    }

    private let defaultsKey = "com.azuic.paguro.snapshot"
    private let defaults: UserDefaults
    private lazy var claudeBridgeMonitor = ClaudeStatusBridgeMonitor { [weak self] snapshot, modifiedAt in
        Task { @MainActor [weak self] in
            self?.applyClaudeBridgeSnapshot(snapshot, modifiedAt: modifiedAt)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let initialSnapshot: PaguroSnapshot
        if
            let data = defaults.data(forKey: defaultsKey),
            let snapshot = try? JSONDecoder().decode(PaguroSnapshot.self, from: data)
        {
            initialSnapshot = snapshot
        } else {
            initialSnapshot = .seed
        }

        pets = initialSnapshot.pets
        selection = initialSnapshot.selection
        selectedProvider = initialSnapshot.selectedProvider
        telemetry = initialSnapshot.telemetry
        desktopPetEnabled = initialSnapshot.desktopPetEnabled

        normalizeState()
        claudeBridgeMonitor.start()
    }

    var activePet: PaguroPet {
        guard let pet = activePet(for: selectedProvider) else {
            return pets[0]
        }

        return pet
    }

    var activeShopListings: [ShopListing] {
        let pet = activePet
        var listings = FoodKind.allCases.map { food in
            ShopListing(
                kind: .food(food),
                title: food.displayName,
                detail: food.shortDetail,
                badge: "\(food.price)",
                isAffordable: pet.energy >= food.price,
                isOwned: false
            )
        }

        for shell in ShellVariant.allCases {
            let owned = pet.inventory.ownedShells.contains(shell)
            listings.append(
                ShopListing(
                    kind: .shell(shell),
                    title: shell.displayName,
                    detail: owned ? "Owned" : "New shell",
                    badge: owned ? "Owned" : "\(shell.price)",
                    isAffordable: owned || pet.energy >= shell.price,
                    isOwned: owned
                )
            )
        }

        listings.append(
            ShopListing(
                kind: .egg,
                title: "Salt Egg",
                detail: "Hatch a new paguro",
                badge: "\(eggPrice)",
                isAffordable: pet.energy >= eggPrice,
                isOwned: false
            )
        )

        return listings
    }

    var activeBagListings: [BagListing] {
        let pet = activePet
        var listings: [BagListing] = []

        for food in FoodKind.allCases {
            let count = pet.inventory.count(for: food)
            guard count > 0 else {
                continue
            }

            listings.append(
                BagListing(
                    kind: .food(food),
                    title: food.displayName,
                    detail: "Feed / \(food.pattern.displayName)",
                    badge: "x\(count)",
                    isEquipped: false
                )
            )
        }

        for shell in pet.inventory.ownedShells {
            listings.append(
                BagListing(
                    kind: .shell(shell),
                    title: shell.displayName,
                    detail: shell == pet.shell ? "Equipped" : "Equip shell",
                    badge: shell == pet.shell ? "On" : "Use",
                    isEquipped: shell == pet.shell
                )
            )
        }

        if pet.inventory.eggs > 0 {
            listings.append(
                BagListing(
                    kind: .egg,
                    title: "Salt Egg",
                    detail: "Hatch a sibling pet",
                    badge: "x\(pet.inventory.eggs)",
                    isEquipped: false
                )
            )
        }

        return listings
    }

    var selectedProviderStatusTitle: String {
        switch selectedProvider {
        case .claude:
            return telemetry.claude.isActive ? "Claude Live" : "Await Claude"
        case .openAI:
            return "Pulse"
        }
    }

    var selectedProviderStatusSubtitle: String {
        switch selectedProvider {
        case .claude:
            return claudeStatusSubtitle
        case .openAI:
            return "OpenAI demo +"
        }
    }

    var selectedProviderActivityLabel: String {
        switch selectedProvider {
        case .claude:
            return "Bridge / \(telemetry.claude.statusLine)"
        case .openAI:
            return "Telemetry / Demo"
        }
    }

    var selectedProviderUsageSummary: String {
        switch selectedProvider {
        case .claude:
            let input = telemetry.claude.lastCurrentInputTokens ?? 0
            let output = telemetry.claude.lastCurrentOutputTokens ?? 0
            if input == 0 && output == 0 {
                return "Awaiting Claude status line"
            }

            return "Last call \(input) in / \(output) out"
        case .openAI:
            return "Proxy adapter not wired yet"
        }
    }

    func select(_ provider: ProviderKind) {
        guard selectedProvider != provider else { return }
        selectedProvider = provider
        normalizeState()
    }

    func providerPets(for provider: ProviderKind) -> [PaguroPet] {
        pets.filter { $0.provider == provider }
    }

    func isSelectedPet(_ pet: PaguroPet) -> Bool {
        selectedPetID(for: pet.provider) == pet.id
    }

    func selectPet(_ petID: UUID) {
        guard let pet = pets.first(where: { $0.id == petID }) else {
            return
        }

        selection.setPetID(petID, for: pet.provider)
        if selectedProvider != pet.provider {
            selectedProvider = pet.provider
        }
        save()
    }

    func refreshSelectedProviderTelemetry() {
        switch selectedProvider {
        case .claude:
            claudeBridgeMonitor.refreshNow()
        case .openAI:
            simulateUsagePulse()
        }
    }

    func toggleDesktopPetVisibility() {
        desktopPetEnabled.toggle()
    }

    func playWithActivePet() {
        mutateActivePet { pet in
            guard pet.energy >= 30 else { return }
            pet.energy -= 30
            pet.growth += 7
            pet.fullness -= 4
        }
    }

    func buyShopItem(_ kind: ShopItemKind) {
        mutateActivePet { pet in
            switch kind {
            case .food(let food):
                guard pet.energy >= food.price else { return }
                pet.energy -= food.price
                pet.inventory.addFood(food)
            case .shell(let shell):
                guard !pet.inventory.ownedShells.contains(shell) else { return }
                guard pet.energy >= shell.price else { return }
                pet.energy -= shell.price
                pet.inventory.addShell(shell)
            case .egg:
                guard pet.energy >= eggPrice else { return }
                pet.energy -= eggPrice
                pet.inventory.addEgg()
            }
        }
    }

    func useBagItem(_ kind: BagItemKind) {
        switch kind {
        case .food(let food):
            mutateActivePet { pet in
                guard pet.inventory.consumeFood(food) else { return }
                pet.fullness += food.fullnessGain
                pet.bodyHue += food.hueShift
                pet.pattern = food.pattern
                pet.growth += 2
            }
        case .shell(let shell):
            mutateActivePet { pet in
                guard pet.inventory.ownedShells.contains(shell) else { return }
                pet.shell = shell
            }
        case .egg:
            hatchEggForActiveProvider()
        }
    }

    func simulateUsagePulse() {
        let provider = selectedProvider

        mutateSelectedPet(for: provider) { pet in
            pet.energy += pet.provider == .claude ? 140 : 120
            pet.growth += 5
            pet.fullness -= 3
            pet.lastUsagePulseAt = Date()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { [weak self] in
            Task { @MainActor [weak self] in
                self?.clearUsagePulse(for: provider)
            }
        }
    }

    private var eggPrice: Int { 240 }

    private func selectedPetID(for provider: ProviderKind) -> UUID? {
        selection.petID(for: provider)
    }

    private func activePet(for provider: ProviderKind) -> PaguroPet? {
        if let petID = selectedPetID(for: provider) {
            return pets.first(where: { $0.provider == provider && $0.id == petID })
        }

        return pets.first(where: { $0.provider == provider })
    }

    private func selectedPetIndex(for provider: ProviderKind) -> Int? {
        if let petID = selectedPetID(for: provider),
           let index = pets.firstIndex(where: { $0.provider == provider && $0.id == petID }) {
            return index
        }

        return pets.firstIndex(where: { $0.provider == provider })
    }

    private func mutateActivePet(_ update: (inout PaguroPet) -> Void) {
        mutateSelectedPet(for: selectedProvider, update)
    }

    private func mutateSelectedPet(for provider: ProviderKind, _ update: (inout PaguroPet) -> Void) {
        guard let index = selectedPetIndex(for: provider) else {
            return
        }

        update(&pets[index])
        pets[index].syncDerivedState()
        normalizeState()
        save()
    }

    private func clearUsagePulse(for provider: ProviderKind) {
        guard let index = selectedPetIndex(for: provider) else {
            return
        }

        pets[index].lastUsagePulseAt = nil
        save()
    }

    private func hatchEggForActiveProvider() {
        guard let index = selectedPetIndex(for: selectedProvider) else {
            return
        }

        guard pets[index].inventory.consumeEgg() else {
            return
        }

        let newPet = makeHatchedPet(for: selectedProvider)
        pets[index].syncDerivedState()
        pets.append(newPet)
        selection.setPetID(newPet.id, for: selectedProvider)
        normalizeState()
        save()
    }

    private func makeHatchedPet(for provider: ProviderKind) -> PaguroPet {
        let names: [String]

        switch provider {
        case .claude:
            names = ["Miso", "Tango", "Pico", "Dune", "Nori", "Kiki"]
        case .openAI:
            names = ["Rook", "Byte", "Sumi", "Pebble", "Mochi", "Aster"]
        }

        let shell = ShellVariant.allCases.randomElement() ?? .sand
        let hue = Double(Int.random(in: 0...359))
        let name = names.randomElement() ?? "Pebble"

        return PaguroPet(
            provider: provider,
            name: name,
            energy: 180,
            fullness: 70,
            growth: 10,
            shell: shell,
            bodyHue: hue,
            pattern: PetPattern.allCases.randomElement() ?? .plain,
            inventory: .starter(currentShell: shell)
        )
    }

    private func normalizeState() {
        for index in pets.indices {
            pets[index].syncDerivedState()
        }

        for provider in ProviderKind.allCases {
            let currentID = selection.petID(for: provider)
            let hasCurrent = pets.contains(where: { $0.provider == provider && $0.id == currentID })
            if !hasCurrent {
                let fallback = pets.first(where: { $0.provider == provider })?.id
                selection.setPetID(fallback, for: provider)
            }
        }

        if activePet(for: selectedProvider) == nil,
           let fallbackProvider = ProviderKind.allCases.first(where: { activePet(for: $0) != nil }) {
            selectedProvider = fallbackProvider
        }
    }

    private func save() {
        let snapshot = PaguroSnapshot(
            selectedProvider: selectedProvider,
            selection: selection,
            pets: pets,
            telemetry: telemetry,
            desktopPetEnabled: desktopPetEnabled
        )

        guard let data = try? JSONEncoder().encode(snapshot) else {
            return
        }

        defaults.set(data, forKey: defaultsKey)
    }

    private func applyClaudeBridgeSnapshot(_ snapshot: ClaudeStatusBridgeSnapshot, modifiedAt: Date) {
        let previousCursor = telemetry.claude.sessions[snapshot.sessionID]
        let inputDelta = max(0, snapshot.contextWindow.totalInputTokens - (previousCursor?.totalInputTokens ?? 0))
        let outputDelta = max(0, snapshot.contextWindow.totalOutputTokens - (previousCursor?.totalOutputTokens ?? 0))
        let energyGain = calculateClaudeEnergyGain(inputDelta: inputDelta, outputDelta: outputDelta)

        telemetry.claude.sessions[snapshot.sessionID] = ClaudeSessionCursor(
            totalInputTokens: snapshot.contextWindow.totalInputTokens,
            totalOutputTokens: snapshot.contextWindow.totalOutputTokens
        )
        telemetry.claude.lastSnapshotAt = modifiedAt
        telemetry.claude.lastSessionID = snapshot.sessionID
        telemetry.claude.lastSessionName = snapshot.sessionName
        telemetry.claude.lastModelDisplayName = snapshot.model.displayName
        telemetry.claude.lastCurrentInputTokens = snapshot.contextWindow.currentUsage?.inputTokens
        telemetry.claude.lastCurrentOutputTokens = snapshot.contextWindow.currentUsage?.outputTokens
        telemetry.claude.lastTotalInputTokens = snapshot.contextWindow.totalInputTokens
        telemetry.claude.lastTotalOutputTokens = snapshot.contextWindow.totalOutputTokens
        telemetry.claude.lastEnergyGain = energyGain > 0 ? energyGain : telemetry.claude.lastEnergyGain

        if energyGain > 0 {
            applyClaudeEnergyGain(energyGain, modifiedAt: modifiedAt)
        }

        save()
    }

    private func applyClaudeEnergyGain(_ energyGain: Int, modifiedAt: Date) {
        guard let index = selectedPetIndex(for: .claude) else {
            return
        }

        pets[index].energy += energyGain
        pets[index].growth += growthGain(for: energyGain)
        pets[index].fullness -= fullnessDrain(for: energyGain)
        pets[index].lastUsagePulseAt = modifiedAt
        pets[index].syncDerivedState()
        telemetry.claude.lastUsageAppliedAt = modifiedAt

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { [weak self] in
            Task { @MainActor [weak self] in
                self?.clearUsagePulse(for: .claude)
            }
        }
    }

    private func calculateClaudeEnergyGain(inputDelta: Int, outputDelta: Int) -> Int {
        let totalDelta = inputDelta + outputDelta
        guard totalDelta > 0 else {
            return 0
        }

        return max(1, totalDelta / 40)
    }

    private func growthGain(for energyGain: Int) -> Int {
        max(1, min(8, energyGain / 45 + 1))
    }

    private func fullnessDrain(for energyGain: Int) -> Int {
        max(1, min(5, energyGain / 60 + 1))
    }

    private var claudeStatusSubtitle: String {
        if telemetry.claude.isActive {
            let energy = telemetry.claude.lastEnergyGain ?? 0
            if energy > 0 {
                return "+\(energy) energy from live usage"
            }

            return "Watching current Claude sessions"
        }

        if let lastSnapshotAt = telemetry.claude.lastSnapshotAt {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            return "Last seen \(formatter.localizedString(for: lastSnapshotAt, relativeTo: Date()))"
        }

        return "Install status line bridge"
    }
}

private struct PaguroSnapshot: Codable {
    var selectedProvider: ProviderKind
    var selection: PetSelectionState
    var pets: [PaguroPet]
    var telemetry: ProviderTelemetryState
    var desktopPetEnabled: Bool

    private enum CodingKeys: String, CodingKey {
        case selectedProvider
        case selection
        case pets
        case telemetry
        case desktopPetEnabled
    }

    init(
        selectedProvider: ProviderKind,
        selection: PetSelectionState,
        pets: [PaguroPet],
        telemetry: ProviderTelemetryState,
        desktopPetEnabled: Bool
    ) {
        self.selectedProvider = selectedProvider
        self.selection = selection
        self.pets = pets
        self.telemetry = telemetry
        self.desktopPetEnabled = desktopPetEnabled
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let pets = try container.decode([PaguroPet].self, forKey: .pets)

        self.pets = pets
        selectedProvider = try container.decodeIfPresent(ProviderKind.self, forKey: .selectedProvider) ?? .claude
        selection = try container.decodeIfPresent(PetSelectionState.self, forKey: .selection) ?? PetSelectionState(
            claudePetID: pets.first(where: { $0.provider == .claude })?.id,
            openAIPetID: pets.first(where: { $0.provider == .openAI })?.id
        )
        telemetry = try container.decodeIfPresent(ProviderTelemetryState.self, forKey: .telemetry) ?? ProviderTelemetryState()
        desktopPetEnabled = try container.decodeIfPresent(Bool.self, forKey: .desktopPetEnabled) ?? true
    }

    static let seed = PaguroSnapshot(
        selectedProvider: .claude,
        selection: PetSelectionState(),
        pets: [
            PaguroPet(
                provider: .claude,
                name: "Pinchy",
                energy: 1240,
                fullness: 62,
                growth: 41,
                shell: .sand,
                bodyHue: 8,
                pattern: .plain
            ),
            PaguroPet(
                provider: .openAI,
                name: "Rook",
                energy: 860,
                fullness: 54,
                growth: 29,
                shell: .lagoon,
                bodyHue: 18,
                pattern: .speckles
            ),
        ],
        telemetry: ProviderTelemetryState(),
        desktopPetEnabled: true
    )
}
