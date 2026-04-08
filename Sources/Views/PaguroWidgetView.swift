import SwiftUI

struct PaguroWidgetView: View {
    @EnvironmentObject private var store: PaguroStore
    @State private var panelMode: InventoryPanelMode = .shop

    var body: some View {
        let pet = store.activePet

        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                headerCard(for: pet)
                petDock
                habitatCard(for: pet)
                telemetryCard
                inventoryCard(for: pet)
            }
            .padding(14)
        }
        .background(background)
    }

    private func headerCard(for pet: PaguroPet) -> some View {
        widgetCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Paguro")
                            .font(PaguroTheme.titleFont(size: 24))
                            .foregroundStyle(PaguroTheme.textPrimary)

                        Text("Hermit crab companion")
                            .font(PaguroTheme.metaFont(size: 12))
                            .foregroundStyle(PaguroTheme.textSecondary)
                    }

                    Spacer(minLength: 8)

                    VStack(alignment: .trailing, spacing: 8) {
                        HStack(spacing: 6) {
                            pillTag(title: pet.provider.displayName, fill: PaguroTheme.accentSoft, foreground: PaguroTheme.accent)
                            pillTag(title: pet.mood.displayName, fill: PaguroTheme.cardMuted, foreground: PaguroTheme.textPrimary)
                        }

                        HStack(spacing: 6) {
                            Circle()
                                .fill(connectionTint)
                                .frame(width: 8, height: 8)

                            Text(store.selectedProviderStatusTitle)
                                .font(PaguroTheme.metaFont(size: 12, weight: .semibold))
                                .foregroundStyle(PaguroTheme.textSecondary)
                        }
                    }
                }

                HStack(spacing: 8) {
                    ForEach(ProviderKind.allCases) { provider in
                        providerButton(for: provider)
                    }
                }

                desktopPetButton
            }
        }
    }

    private var petDock: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(store.providerPets(for: store.selectedProvider)) { pet in
                    Button {
                        store.selectPet(pet.id)
                    } label: {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(store.isSelectedPet(pet) ? PaguroTheme.accent : PaguroTheme.seafoam)
                                .frame(width: 10, height: 10)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(pet.name)
                                    .font(PaguroTheme.bodyFont(size: 14, weight: .semibold))
                                    .foregroundStyle(PaguroTheme.textPrimary)
                                    .lineLimit(1)

                                Text("\(pet.stage.displayName) • \(pet.weightText)")
                                    .font(PaguroTheme.metaFont(size: 11))
                                    .foregroundStyle(PaguroTheme.textSecondary)
                                    .lineLimit(1)
                            }

                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(width: 138, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(store.isSelectedPet(pet) ? PaguroTheme.card : PaguroTheme.white.opacity(0.72))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(store.isSelectedPet(pet) ? PaguroTheme.accent.opacity(0.35) : PaguroTheme.borderSoft, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 1)
        }
    }

    private func habitatCard(for pet: PaguroPet) -> some View {
        widgetCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pet.name)
                            .font(PaguroTheme.titleFont(size: 28))
                            .foregroundStyle(PaguroTheme.textPrimary)

                        Text("\(pet.stage.displayName) • \(pet.weightText)")
                            .font(PaguroTheme.bodyFont(size: 13, weight: .medium))
                            .foregroundStyle(PaguroTheme.textSecondary)
                    }

                    Spacer(minLength: 8)

                    energyBadge(value: pet.energy)
                }

                habitatScene(for: pet)

                HStack(spacing: 10) {
                    miniStat(title: "Shell", value: shellShortName(pet.shell))
                    miniStat(title: "Pattern", value: pet.pattern.displayName)
                    miniStat(title: "Growth", value: "\(pet.growth)%")
                }

                VStack(spacing: 10) {
                    progressRow(title: "Fullness", value: pet.fullness, tint: PaguroTheme.success)
                    progressRow(title: "Growth", value: pet.growth, tint: PaguroTheme.accent)
                }

                HStack(spacing: 10) {
                    actionButton(
                        title: store.selectedProvider == .claude ? "Sync" : "Pulse",
                        subtitle: store.selectedProvider == .claude ? "Check live usage" : "Generate demo energy",
                        fill: PaguroTheme.accent
                    ) {
                        store.refreshSelectedProviderTelemetry()
                    }

                    actionButton(
                        title: "Play",
                        subtitle: pet.energy >= 30 ? "Spend 30 energy" : "Need 30 energy",
                        fill: PaguroTheme.seafoam,
                        foreground: PaguroTheme.textPrimary,
                        isEnabled: pet.energy >= 30
                    ) {
                        store.playWithActivePet()
                    }
                }

                actionButton(
                    title: store.desktopPetEnabled ? "Hide Desktop Paguro" : "Show Desktop Paguro",
                    subtitle: store.desktopPetEnabled ? "Remove the desktop overlay" : "Bring the desktop pet back",
                    fill: PaguroTheme.cardMuted,
                    foreground: PaguroTheme.textPrimary
                ) {
                    store.toggleDesktopPetVisibility()
                }
            }
        }
    }

    private var telemetryCard: some View {
        widgetCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(store.selectedProviderActivityLabel)
                        .font(PaguroTheme.bodyFont(size: 13, weight: .semibold))
                        .foregroundStyle(PaguroTheme.textPrimary)

                    Spacer(minLength: 8)

                    Circle()
                        .fill(connectionTint)
                        .frame(width: 8, height: 8)
                }

                Text(store.selectedProviderStatusSubtitle)
                    .font(PaguroTheme.bodyFont(size: 14, weight: .medium))
                    .foregroundStyle(PaguroTheme.textPrimary)

                Text(store.selectedProviderUsageSummary)
                    .font(PaguroTheme.metaFont(size: 12))
                    .foregroundStyle(PaguroTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func inventoryCard(for pet: PaguroPet) -> some View {
        widgetCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(panelMode == .shop ? "Shop" : "Bag")
                            .font(PaguroTheme.titleFont(size: 20))
                            .foregroundStyle(PaguroTheme.textPrimary)

                        Text(panelMode == .shop ? "Spend energy on treats, shells, and eggs." : "Use what you already own.")
                            .font(PaguroTheme.metaFont(size: 12))
                            .foregroundStyle(PaguroTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 8)

                    HStack(spacing: 6) {
                        sectionButton(for: .shop)
                        sectionButton(for: .bag)
                    }
                }

                HStack(spacing: 8) {
                    countPill(title: "Shells", value: "\(pet.inventory.ownedShells.count)")
                    countPill(title: "Food", value: "\(foodCount(for: pet))")
                    countPill(title: "Eggs", value: "\(pet.inventory.eggs)")
                }

                VStack(spacing: 10) {
                    if panelMode == .shop {
                        ForEach(store.activeShopListings) { listing in
                            shopRow(for: listing)
                        }
                    } else if store.activeBagListings.isEmpty {
                        emptyInventoryState
                    } else {
                        ForEach(store.activeBagListings) { listing in
                            bagRow(for: listing)
                        }
                    }
                }
            }
        }
    }

    private func providerButton(for provider: ProviderKind) -> some View {
        Button {
            store.select(provider)
        } label: {
            Text(provider.displayName)
                .font(PaguroTheme.bodyFont(size: 13, weight: .semibold))
                .foregroundStyle(store.selectedProvider == provider ? PaguroTheme.white : PaguroTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    Capsule(style: .continuous)
                        .fill(store.selectedProvider == provider ? PaguroTheme.accent : PaguroTheme.white)
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(store.selectedProvider == provider ? PaguroTheme.accent.opacity(0.25) : PaguroTheme.borderSoft, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var desktopPetButton: some View {
        Button {
            store.toggleDesktopPetVisibility()
        } label: {
            HStack(spacing: 10) {
                Circle()
                    .fill(store.desktopPetEnabled ? PaguroTheme.success : PaguroTheme.borderSoft)
                    .frame(width: 10, height: 10)

                VStack(alignment: .leading, spacing: 2) {
                    Text(store.desktopPetEnabled ? "Desktop pet is live" : "Desktop pet is hidden")
                        .font(PaguroTheme.bodyFont(size: 13, weight: .semibold))
                        .foregroundStyle(PaguroTheme.textPrimary)

                    Text(store.desktopPetEnabled ? "Hide overlay" : "Show overlay")
                        .font(PaguroTheme.metaFont(size: 11))
                        .foregroundStyle(PaguroTheme.textSecondary)
                }

                Spacer(minLength: 8)

                Text(store.desktopPetEnabled ? "On" : "Off")
                    .font(PaguroTheme.metaFont(size: 11, weight: .semibold))
                    .foregroundStyle(store.desktopPetEnabled ? PaguroTheme.success : PaguroTheme.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(store.desktopPetEnabled ? PaguroTheme.success.opacity(0.16) : PaguroTheme.cardMuted)
                    )
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(PaguroTheme.white.opacity(0.72))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(PaguroTheme.borderSoft, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func pillTag(title: String, fill: Color, foreground: Color) -> some View {
        Text(title)
            .font(PaguroTheme.metaFont(size: 11, weight: .semibold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(fill)
            )
    }

    private func energyBadge(value: Int) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("Energy")
                .font(PaguroTheme.metaFont(size: 11, weight: .semibold))
                .foregroundStyle(PaguroTheme.textSecondary)

            Text(value.formatted())
                .font(PaguroTheme.titleFont(size: 20))
                .foregroundStyle(PaguroTheme.accent)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(PaguroTheme.accentSoft)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(PaguroTheme.accent.opacity(0.18), lineWidth: 1)
        )
    }

    private func habitatScene(for pet: PaguroPet) -> some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [PaguroTheme.seafoam, PaguroTheme.water.opacity(0.72), Color.white.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 0) {
                Spacer()

                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(PaguroTheme.sandSoft)
                    .frame(height: 90)
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(PaguroTheme.sandDark.opacity(0.45))
                            .frame(height: 1)
                    }
            }

            HStack {
                Circle()
                    .fill(Color.white.opacity(0.34))
                    .frame(width: 10, height: 10)
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 6, height: 6)
                Spacer()
                Circle()
                    .fill(Color.white.opacity(0.26))
                    .frame(width: 8, height: 8)
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .frame(maxHeight: .infinity, alignment: .top)

            PaguroPetSpriteView(pet: pet)
                .frame(width: 144, height: 144)
                .padding(.bottom, 4)
                .scaleEffect(pet.mood == .charged ? 1.04 : 1)
                .animation(.easeInOut(duration: 0.18), value: pet.mood)
                .animation(.easeInOut(duration: 0.18), value: pet.pattern)
                .animation(.easeInOut(duration: 0.18), value: pet.shell)
        }
        .frame(height: 208)
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(PaguroTheme.borderSoft, lineWidth: 1)
        )
    }

    private func miniStat(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(PaguroTheme.metaFont(size: 11, weight: .semibold))
                .foregroundStyle(PaguroTheme.textSecondary)

            Text(value)
                .font(PaguroTheme.bodyFont(size: 14, weight: .semibold))
                .foregroundStyle(PaguroTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(PaguroTheme.cardMuted)
        )
    }

    private func progressRow(title: String, value: Int, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(PaguroTheme.bodyFont(size: 13, weight: .semibold))
                    .foregroundStyle(PaguroTheme.textPrimary)

                Spacer()

                Text("\(value)%")
                    .font(PaguroTheme.metaFont(size: 11, weight: .semibold))
                    .foregroundStyle(PaguroTheme.textSecondary)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(PaguroTheme.cardMuted)

                    Capsule(style: .continuous)
                        .fill(tint)
                        .frame(width: proxy.size.width * (CGFloat(value) / 100))
                }
            }
            .frame(height: 10)
        }
    }

    private func actionButton(
        title: String,
        subtitle: String,
        fill: Color,
        foreground: Color = .white,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(PaguroTheme.bodyFont(size: 14, weight: .semibold))

                Text(subtitle)
                    .font(PaguroTheme.metaFont(size: 11))
                    .opacity(0.85)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(fill)
            )
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.55)
        .disabled(!isEnabled)
    }

    private func sectionButton(for mode: InventoryPanelMode) -> some View {
        Button {
            panelMode = mode
        } label: {
            Text(mode.displayName)
                .font(PaguroTheme.metaFont(size: 12, weight: .semibold))
                .foregroundStyle(panelMode == mode ? PaguroTheme.white : PaguroTheme.textPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(panelMode == mode ? PaguroTheme.textPrimary : PaguroTheme.cardMuted)
                )
        }
        .buttonStyle(.plain)
    }

    private func countPill(title: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(title)
                .font(PaguroTheme.metaFont(size: 10, weight: .semibold))
                .foregroundStyle(PaguroTheme.textSecondary)

            Text(value)
                .font(PaguroTheme.bodyFont(size: 15, weight: .semibold))
                .foregroundStyle(PaguroTheme.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(PaguroTheme.cardMuted)
        )
    }

    private func shopRow(for listing: ShopListing) -> some View {
        let visual = itemVisual(for: listing.kind)
        let isDisabled = listing.isOwned || !listing.isAffordable

        return inventoryRow(
            title: listing.title,
            detail: listing.detail,
            badge: listing.badge,
            visual: visual,
            buttonTitle: listing.isOwned ? "Owned" : "Buy",
            buttonFill: isDisabled && !listing.isOwned ? PaguroTheme.cardMuted : visual.tint,
            buttonForeground: isDisabled && !listing.isOwned ? PaguroTheme.textSecondary : .white,
            isEnabled: !isDisabled,
            action: { store.buyShopItem(listing.kind) }
        )
    }

    private func bagRow(for listing: BagListing) -> some View {
        let visual = itemVisual(for: listing.kind)
        let isDisabled = listing.isEquipped

        return inventoryRow(
            title: listing.title,
            detail: listing.detail,
            badge: listing.badge,
            visual: visual,
            buttonTitle: isDisabled ? "On" : actionTitle(for: listing.kind),
            buttonFill: isDisabled ? PaguroTheme.cardMuted : visual.tint,
            buttonForeground: isDisabled ? PaguroTheme.textSecondary : .white,
            isEnabled: !isDisabled,
            action: { store.useBagItem(listing.kind) }
        )
    }

    private var emptyInventoryState: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Nothing here yet")
                .font(PaguroTheme.bodyFont(size: 14, weight: .semibold))
                .foregroundStyle(PaguroTheme.textPrimary)

            Text("Buy food, shells, or eggs from the shop to start shaping this paguro.")
                .font(PaguroTheme.metaFont(size: 12))
                .foregroundStyle(PaguroTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(PaguroTheme.cardMuted)
        )
    }

    private func inventoryRow(
        title: String,
        detail: String,
        badge: String,
        visual: WidgetItemVisual,
        buttonTitle: String,
        buttonFill: Color,
        buttonForeground: Color,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 12) {
            itemIcon(visual)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(PaguroTheme.bodyFont(size: 14, weight: .semibold))
                    .foregroundStyle(PaguroTheme.textPrimary)

                Text(detail)
                    .font(PaguroTheme.metaFont(size: 12))
                    .foregroundStyle(PaguroTheme.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 8) {
                Text(badge)
                    .font(PaguroTheme.metaFont(size: 11, weight: .semibold))
                    .foregroundStyle(visual.tint)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        Capsule(style: .continuous)
                            .fill(visual.tint.opacity(0.14))
                    )

                Button(buttonTitle, action: action)
                    .font(PaguroTheme.metaFont(size: 11, weight: .semibold))
                    .foregroundStyle(buttonForeground)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(buttonFill)
                    )
                    .buttonStyle(.plain)
                    .disabled(!isEnabled)
                    .opacity(isEnabled || buttonTitle == "Owned" || buttonTitle == "On" ? 1 : 0.6)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(PaguroTheme.cardMuted)
        )
    }

    private func itemIcon(_ visual: WidgetItemVisual) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(visual.tint.opacity(0.16))

            Text(visual.code)
                .font(PaguroTheme.metaFont(size: 12, weight: .bold))
                .foregroundStyle(visual.tint)
        }
        .frame(width: 42, height: 42)
    }

    private var connectionTint: Color {
        switch store.selectedProvider {
        case .claude:
            return store.telemetry.claude.isActive ? PaguroTheme.success : PaguroTheme.accent
        case .openAI:
            return PaguroTheme.accent
        }
    }

    private func shellShortName(_ shell: ShellVariant) -> String {
        switch shell {
        case .sand:
            return "Sand"
        case .sunset:
            return "Sunset"
        case .lagoon:
            return "Lagoon"
        }
    }

    private func foodCount(for pet: PaguroPet) -> Int {
        FoodKind.allCases.reduce(into: 0) { partialResult, food in
            partialResult += pet.inventory.count(for: food)
        }
    }

    private func actionTitle(for kind: BagItemKind) -> String {
        switch kind {
        case .food:
            return "Feed"
        case .shell:
            return "Wear"
        case .egg:
            return "Hatch"
        }
    }

    private func itemVisual(for kind: ShopItemKind) -> WidgetItemVisual {
        switch kind {
        case .food(let food):
            return itemVisual(for: food)
        case .shell(let shell):
            return itemVisual(for: shell)
        case .egg:
            return WidgetItemVisual(code: "EG", tint: PaguroTheme.accent)
        }
    }

    private func itemVisual(for kind: BagItemKind) -> WidgetItemVisual {
        switch kind {
        case .food(let food):
            return itemVisual(for: food)
        case .shell(let shell):
            return itemVisual(for: shell)
        case .egg:
            return WidgetItemVisual(code: "EG", tint: PaguroTheme.accent)
        }
    }

    private func itemVisual(for food: FoodKind) -> WidgetItemVisual {
        switch food {
        case .berryBits:
            return WidgetItemVisual(code: "BB", tint: PaguroTheme.accent)
        case .kelpCrunch:
            return WidgetItemVisual(code: "KC", tint: PaguroTheme.success)
        case .sunMorsel:
            return WidgetItemVisual(code: "SM", tint: PaguroTheme.gold)
        }
    }

    private func itemVisual(for shell: ShellVariant) -> WidgetItemVisual {
        switch shell {
        case .sand:
            return WidgetItemVisual(code: "SA", tint: PaguroTheme.sandDark)
        case .sunset:
            return WidgetItemVisual(code: "SU", tint: PaguroTheme.accent)
        case .lagoon:
            return WidgetItemVisual(code: "LG", tint: PaguroTheme.water)
        }
    }

    private func widgetCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(PaguroTheme.card)
                    .shadow(color: Color.black.opacity(0.06), radius: 18, x: 0, y: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(PaguroTheme.borderSoft, lineWidth: 1)
            )
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [PaguroTheme.canvasTop, PaguroTheme.canvasBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(PaguroTheme.accentSoft.opacity(0.5))
                .frame(width: 180, height: 180)
                .blur(radius: 40)
                .offset(x: -130, y: -170)

            Circle()
                .fill(PaguroTheme.seafoam.opacity(0.45))
                .frame(width: 200, height: 200)
                .blur(radius: 46)
                .offset(x: 130, y: -70)

            Circle()
                .fill(PaguroTheme.lilac.opacity(0.28))
                .frame(width: 220, height: 220)
                .blur(radius: 52)
                .offset(x: 120, y: 260)
        }
        .ignoresSafeArea()
    }
}

private enum InventoryPanelMode: String, CaseIterable, Identifiable {
    case shop
    case bag

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .shop:
            return "Shop"
        case .bag:
            return "Bag"
        }
    }
}

private struct WidgetItemVisual {
    let code: String
    let tint: Color
}
