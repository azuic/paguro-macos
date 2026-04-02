import Foundation

@MainActor
final class PaguroStore: ObservableObject {
    @Published private(set) var pets: [PaguroPet]
    @Published var selectedProvider: ProviderKind {
        didSet {
            save()
        }
    }

    private let defaultsKey = "com.azuic.paguro.snapshot"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if
            let data = defaults.data(forKey: defaultsKey),
            let snapshot = try? JSONDecoder().decode(PaguroSnapshot.self, from: data)
        {
            pets = snapshot.pets
            selectedProvider = snapshot.selectedProvider
        } else {
            let seed = PaguroSnapshot.seed
            pets = seed.pets
            selectedProvider = seed.selectedProvider
        }
    }

    var activePet: PaguroPet {
        pets.first(where: { $0.provider == selectedProvider }) ?? pets[0]
    }

    func select(_ provider: ProviderKind) {
        guard selectedProvider != provider else { return }
        selectedProvider = provider
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
            pets: pets
        )

        guard let data = try? JSONEncoder().encode(snapshot) else {
            return
        }

        defaults.set(data, forKey: defaultsKey)
    }
}

private struct PaguroSnapshot: Codable {
    var selectedProvider: ProviderKind
    var pets: [PaguroPet]

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
        ]
    )
}
