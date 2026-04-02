import Foundation

@MainActor
final class PaguroStore: ObservableObject {
    @Published private(set) var pets: [PaguroPet]
    @Published private(set) var telemetry: ProviderTelemetryState
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
        selectedProvider = initialSnapshot.selectedProvider
        telemetry = initialSnapshot.telemetry

        claudeBridgeMonitor.start()
    }

    var activePet: PaguroPet {
        pets.first(where: { $0.provider == selectedProvider }) ?? pets[0]
    }

    func select(_ provider: ProviderKind) {
        guard selectedProvider != provider else { return }
        selectedProvider = provider
    }

    func refreshSelectedProviderTelemetry() {
        switch selectedProvider {
        case .claude:
            claudeBridgeMonitor.refreshNow()
        case .openAI:
            simulateUsagePulse()
        }
    }

    func simulateUsagePulse() {
        let provider = selectedProvider

        mutatePet(for: provider) { pet in
            pet.energy += pet.provider == .claude ? 140 : 120
            pet.growth = min(100, pet.growth + 5)
            pet.fullness = max(0, pet.fullness - 3)
            pet.lastUsagePulseAt = Date()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { [weak self] in
            guard let self else { return }

            self.mutatePet(for: provider) { pet in
                pet.lastUsagePulseAt = nil
            }
        }
    }

    func feedActivePet() {
        mutateActivePet { pet in
            guard pet.energy >= 40 else { return }
            pet.energy -= 40
            pet.fullness = min(100, pet.fullness + 18)
            pet.bodyHue = (pet.bodyHue + 12).truncatingRemainder(dividingBy: 360)
        }
    }

    func playWithActivePet() {
        mutateActivePet { pet in
            guard pet.energy >= 30 else { return }
            pet.energy -= 30
            pet.growth = min(100, pet.growth + 7)
            pet.fullness = max(0, pet.fullness - 4)
        }
    }

    func buyNextShell() {
        mutateActivePet { pet in
            let next = pet.shell.next
            guard pet.energy >= next.price else { return }
            pet.energy -= next.price
            pet.shell = next
        }
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

    private func mutateActivePet(_ update: (inout PaguroPet) -> Void) {
        mutatePet(for: selectedProvider, update)
    }

    private func mutatePet(for provider: ProviderKind, _ update: (inout PaguroPet) -> Void) {
        guard let index = pets.firstIndex(where: { $0.provider == provider }) else {
            return
        }

        update(&pets[index])
        save()
    }

    private func save() {
        let snapshot = PaguroSnapshot(
            selectedProvider: selectedProvider,
            pets: pets,
            telemetry: telemetry
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
        guard let index = pets.firstIndex(where: { $0.provider == .claude }) else {
            return
        }

        pets[index].energy += energyGain
        pets[index].growth = min(100, pets[index].growth + growthGain(for: energyGain))
        pets[index].fullness = max(0, pets[index].fullness - fullnessDrain(for: energyGain))
        pets[index].lastUsagePulseAt = modifiedAt
        telemetry.claude.lastUsageAppliedAt = modifiedAt

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else { return }
                guard let claudeIndex = self.pets.firstIndex(where: { $0.provider == .claude }) else {
                    return
                }

                self.pets[claudeIndex].lastUsagePulseAt = nil
                self.save()
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
    var pets: [PaguroPet]
    var telemetry: ProviderTelemetryState

    static let seed = PaguroSnapshot(
        selectedProvider: .claude,
        pets: [
            PaguroPet(
                provider: .claude,
                name: "Pinchy",
                energy: 1240,
                fullness: 62,
                growth: 41,
                stage: .adolescent,
                shell: .sand,
                bodyHue: 8
            ),
            PaguroPet(
                provider: .openAI,
                name: "Rook",
                energy: 860,
                fullness: 54,
                growth: 29,
                stage: .hatchling,
                shell: .lagoon,
                bodyHue: 18
            ),
        ],
        telemetry: ProviderTelemetryState()
    )
}
