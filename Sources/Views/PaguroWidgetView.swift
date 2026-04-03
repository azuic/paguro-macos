import SwiftUI

struct PaguroWidgetView: View {
    @EnvironmentObject private var store: PaguroStore
    @State private var panelMode: InventoryPanelMode = .shop

    var body: some View {
        let pet = store.activePet

        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                header(for: pet)
                providerPicker
                petRoster
                providerStatusCard
                terrarium(for: pet)
                statGrid(for: pet)
                quickActions(for: pet)
                panelPicker
                panelContent(for: pet)
            }
            .padding(14)
        }
        .background(background)
    }

    private func header(for pet: PaguroPet) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Paguro")
                    .font(.system(size: 21, weight: .black, design: .rounded))
                    .foregroundStyle(PaguroTheme.rose)

                Text("\(pet.name) / \(pet.stage.displayName) / \(pet.pattern.displayName)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(PaguroTheme.ink)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 6) {
                Text(pet.provider.displayName)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(PaguroTheme.lilac, in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(PaguroTheme.ink, lineWidth: 1.5)
                    )

                Text(pet.mood.displayName)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(PaguroTheme.ink.opacity(0.7))
            }
        }
    }

    private var providerStatusCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(store.selectedProviderStatusTitle.uppercased())
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(PaguroTheme.ink.opacity(0.66))

                Spacer()

                Circle()
                    .fill(store.selectedProvider == .claude && store.telemetry.claude.isActive ? PaguroTheme.mint : PaguroTheme.rose)
                    .frame(width: 8, height: 8)
            }

            Text(store.selectedProviderStatusSubtitle)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(PaguroTheme.ink)

            Text(store.selectedProviderUsageSummary)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(PaguroTheme.ink.opacity(0.72))

            if store.selectedProvider == .claude {
                Text(store.selectedProviderActivityLabel)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(PaguroTheme.ink.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(PaguroTheme.cream.opacity(0.9), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(PaguroTheme.ink, lineWidth: 1.5)
        )
    }

    private var providerPicker: some View {
        HStack(spacing: 8) {
            ForEach(ProviderKind.allCases) { provider in
                Button {
                    store.select(provider)
                } label: {
                    Text(provider.displayName)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(PaguroTheme.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    store.selectedProvider == provider
                                        ? PaguroTheme.lilac
                                        : Color.white.opacity(0.72)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(PaguroTheme.ink, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var petRoster: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(store.providerPets(for: store.selectedProvider)) { pet in
                    petChip(for: pet)
                }
            }
            .padding(.vertical, 1)
        }
    }

    private func petChip(for pet: PaguroPet) -> some View {
        Button {
            store.selectPet(pet.id)
        } label: {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(pet.mood == .charged ? PaguroTheme.gold : PaguroTheme.mint)
                        .frame(width: 8, height: 8)

                    Text(pet.name)
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundStyle(PaguroTheme.ink)
                        .lineLimit(1)
                }

                Text("\(pet.weightText) / \(pet.shell.displayName)")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundStyle(PaguroTheme.ink.opacity(0.7))
                    .lineLimit(1)
            }
            .frame(width: 122, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(store.isSelectedPet(pet) ? PaguroTheme.lilac : Color.white.opacity(0.82))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(PaguroTheme.ink, lineWidth: store.isSelectedPet(pet) ? 2 : 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func terrarium(for pet: PaguroPet) -> some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [PaguroTheme.lagoon, PaguroTheme.cream],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(PaguroTheme.ink, lineWidth: 2)
                )

            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    bubble(size: 10, opacity: 0.24)
                    bubble(size: 6, opacity: 0.16)
                    Spacer()
                    bubble(size: 7, opacity: 0.18)
                    bubble(size: 12, opacity: 0.22)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                Spacer()
            }

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(PaguroTheme.sand)
                .frame(height: 74)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(PaguroTheme.ink.opacity(0.3))
                        .frame(height: 1)
                }

            paguroSprite(for: pet)
                .offset(y: -10)
                .animation(.spring(response: 0.35, dampingFraction: 0.78), value: pet.mood)
                .animation(.spring(response: 0.28, dampingFraction: 0.7), value: pet.shell)
                .animation(.spring(response: 0.28, dampingFraction: 0.78), value: pet.pattern)
        }
        .frame(height: 218)
    }

    private func paguroSprite(for pet: PaguroPet) -> some View {
        ZStack {
            Ellipse()
                .fill(PaguroTheme.ink.opacity(0.12))
                .frame(width: 112, height: 18)
                .offset(y: 42)

            ZStack(alignment: .bottomLeading) {
                shell(for: pet)
                    .offset(x: 18, y: -14)

                crabBody(for: pet)
                    .offset(x: -14, y: 12)
            }
            .scaleEffect(spriteScale(for: pet))
        }
    }

    private func shell(for pet: PaguroPet) -> some View {
        ZStack {
            Circle()
                .fill(PaguroTheme.peach)
                .frame(width: 86, height: 86)
                .overlay(
                    Circle()
                        .stroke(PaguroTheme.ink, lineWidth: 3)
                )
                .hueRotation(.degrees(pet.shell.hueRotation))

            Circle()
                .stroke(PaguroTheme.ink.opacity(0.35), lineWidth: 3)
                .frame(width: 54, height: 54)
                .offset(x: -5, y: 4)
                .hueRotation(.degrees(pet.shell.hueRotation))

            Circle()
                .stroke(PaguroTheme.ink.opacity(0.2), lineWidth: 3)
                .frame(width: 25, height: 25)
                .offset(x: -9, y: 7)
                .hueRotation(.degrees(pet.shell.hueRotation))
        }
    }

    private func crabBody(for pet: PaguroPet) -> some View {
        let bodyTint = Color(hue: pet.bodyHue / 360, saturation: 0.58, brightness: 0.95)

        return ZStack(alignment: .top) {
            HStack(spacing: -8) {
                claw(tint: bodyTint, mirrored: true)
                    .rotationEffect(.degrees(-10))
                    .offset(y: 10)

                claw(tint: bodyTint, mirrored: false)
                    .rotationEffect(.degrees(8))
                    .offset(y: 8)
            }
            .offset(y: 12)

            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    eye()
                    eye()
                }

                ZStack {
                    Capsule()
                        .fill(bodyTint)
                        .frame(width: 62, height: 42)

                    bodyPattern(for: pet, tint: bodyTint)
                        .frame(width: 62, height: 42)

                    Capsule()
                        .stroke(PaguroTheme.ink, lineWidth: 3)
                        .frame(width: 62, height: 42)
                }

                HStack(spacing: 10) {
                    leg()
                    leg()
                    leg()
                }
                .offset(y: -4)
            }
        }
    }

    @ViewBuilder
    private func bodyPattern(for pet: PaguroPet, tint: Color) -> some View {
        switch pet.pattern {
        case .plain:
            EmptyView()
        case .speckles:
            ZStack {
                Circle()
                    .fill(tint.opacity(0.24))
                    .frame(width: 8, height: 8)
                    .offset(x: -12, y: -6)

                Circle()
                    .fill(tint.opacity(0.22))
                    .frame(width: 6, height: 6)
                    .offset(x: 3, y: 2)

                Circle()
                    .fill(tint.opacity(0.28))
                    .frame(width: 7, height: 7)
                    .offset(x: 14, y: -4)

                Circle()
                    .fill(tint.opacity(0.2))
                    .frame(width: 5, height: 5)
                    .offset(x: -1, y: -10)
            }
        case .stripes:
            HStack(spacing: 8) {
                Capsule()
                    .fill(tint.opacity(0.22))
                    .frame(width: 6, height: 30)

                Capsule()
                    .fill(tint.opacity(0.24))
                    .frame(width: 6, height: 30)

                Capsule()
                    .fill(tint.opacity(0.2))
                    .frame(width: 6, height: 30)
            }
        }
    }

    private func claw(tint: Color, mirrored: Bool) -> some View {
        Capsule()
            .fill(tint)
            .frame(width: 26, height: 16)
            .overlay(
                Capsule()
                    .stroke(PaguroTheme.ink, lineWidth: 3)
            )
            .scaleEffect(x: mirrored ? -1 : 1, y: 1)
    }

    private func leg() -> some View {
        Capsule()
            .fill(PaguroTheme.ink)
            .frame(width: 4, height: 18)
    }

    private func eye() -> some View {
        VStack(spacing: 2) {
            Capsule()
                .fill(PaguroTheme.ink)
                .frame(width: 3, height: 16)

            Circle()
                .fill(PaguroTheme.cream)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .fill(PaguroTheme.ink)
                        .frame(width: 4, height: 4)
                )
        }
    }

    private func statGrid(for pet: PaguroPet) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                metricCard(title: "Energy", value: "\(pet.energy)", tint: PaguroTheme.gold, foreground: PaguroTheme.ink)
                metricCard(title: "Weight", value: pet.weightText, tint: PaguroTheme.lilac, foreground: PaguroTheme.ink)
                metricCard(title: "Pattern", value: pet.pattern.displayName, tint: PaguroTheme.peach, foreground: PaguroTheme.ink)
            }

            progressCard(title: "Fullness", value: pet.fullness, tint: PaguroTheme.mint)

            HStack(spacing: 10) {
                progressCard(title: "Growth", value: pet.growth, tint: PaguroTheme.lilac)
                inventoryCard(for: pet)
            }
        }
    }

    private func inventoryCard(for pet: PaguroPet) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("INVENTORY")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(PaguroTheme.ink.opacity(0.65))

            HStack(spacing: 6) {
                inventoryTag(label: "Shell", value: "\(pet.inventory.ownedShells.count)")
                inventoryTag(label: "Food", value: "\(foodCount(for: pet))")
                inventoryTag(label: "Egg", value: "\(pet.inventory.eggs)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(PaguroTheme.cream.opacity(0.92), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(PaguroTheme.ink, lineWidth: 1.5)
        )
    }

    private func inventoryTag(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundStyle(PaguroTheme.ink.opacity(0.55))
            Text(value)
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundStyle(PaguroTheme.ink)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.76), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(PaguroTheme.ink, lineWidth: 1.2)
        )
    }

    private func quickActions(for pet: PaguroPet) -> some View {
        HStack(spacing: 8) {
            actionButton(
                title: store.selectedProvider == .claude ? "Sync Claude" : "Pulse Demo",
                subtitle: store.selectedProviderStatusSubtitle,
                tint: PaguroTheme.rose
            ) {
                store.refreshSelectedProviderTelemetry()
            }

            actionButton(
                title: "Play",
                subtitle: pet.energy >= 30 ? "-30 energy / +growth" : "Need 30 energy",
                tint: PaguroTheme.lilac,
                isEnabled: pet.energy >= 30
            ) {
                store.playWithActivePet()
            }
        }
    }

    private var panelPicker: some View {
        HStack(spacing: 8) {
            ForEach(InventoryPanelMode.allCases) { mode in
                Button {
                    panelMode = mode
                } label: {
                    Text(mode.displayName)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(PaguroTheme.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(panelMode == mode ? PaguroTheme.lagoon : Color.white.opacity(0.72))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(PaguroTheme.ink, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func panelContent(for pet: PaguroPet) -> some View {
        switch panelMode {
        case .shop:
            listingPanel(
                title: "Market Tide",
                subtitle: "Spend energy on food, shells, and eggs",
                rows: store.activeShopListings.map { listing in
                    AnyView(shopRow(for: listing))
                }
            )
        case .bag:
            if store.activeBagListings.isEmpty {
                emptyPanel(
                    title: "Bag Empty",
                    subtitle: "Buy food or eggs from the market to shape this paguro."
                )
            } else {
                listingPanel(
                    title: "Bag + Shell Rack",
                    subtitle: "Use food to change color or pattern, or hatch an egg",
                    rows: store.activeBagListings.map { listing in
                        AnyView(bagRow(for: listing))
                    }
                )
            }
        }
    }

    private func listingPanel(title: String, subtitle: String, rows: [AnyView]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(PaguroTheme.ink)

            Text(subtitle)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(PaguroTheme.ink.opacity(0.68))

            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                row
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(PaguroTheme.cream.opacity(0.96), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(PaguroTheme.ink, lineWidth: 1.5)
        )
    }

    private func emptyPanel(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(PaguroTheme.ink)

            Text(subtitle)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(PaguroTheme.ink.opacity(0.68))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(PaguroTheme.cream.opacity(0.96), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(PaguroTheme.ink, lineWidth: 1.5)
        )
    }

    private func shopRow(for listing: ShopListing) -> some View {
        let canBuy = listing.isAffordable && !listing.isOwned

        return HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(PaguroTheme.ink)

                Text(listing.detail)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(PaguroTheme.ink.opacity(0.68))
            }

            Spacer(minLength: 8)

            Text(listing.badge)
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .foregroundStyle(PaguroTheme.ink)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.78), in: Capsule())
                .overlay(
                    Capsule()
                        .stroke(PaguroTheme.ink, lineWidth: 1.2)
                )

            Button(listing.isOwned ? "Owned" : "Buy") {
                store.buyShopItem(listing.kind)
            }
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(PaguroTheme.ink)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(canBuy ? PaguroTheme.gold : Color.white.opacity(0.65))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(PaguroTheme.ink, lineWidth: 1.4)
            )
            .buttonStyle(.plain)
            .disabled(!canBuy)
            .opacity(canBuy || listing.isOwned ? 1 : 0.7)
        }
        .padding(10)
        .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(PaguroTheme.ink, lineWidth: 1.2)
        )
    }

    private func bagRow(for listing: BagListing) -> some View {
        let canUse = !listing.isEquipped

        return HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(PaguroTheme.ink)

                Text(listing.detail)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(PaguroTheme.ink.opacity(0.68))
            }

            Spacer(minLength: 8)

            Text(listing.badge)
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .foregroundStyle(PaguroTheme.ink)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.78), in: Capsule())
                .overlay(
                    Capsule()
                        .stroke(PaguroTheme.ink, lineWidth: 1.2)
                )

            Button(listing.isEquipped ? "On" : actionTitle(for: listing.kind)) {
                store.useBagItem(listing.kind)
            }
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(PaguroTheme.ink)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(canUse ? PaguroTheme.mint : Color.white.opacity(0.65))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(PaguroTheme.ink, lineWidth: 1.4)
            )
            .buttonStyle(.plain)
            .disabled(!canUse)
            .opacity(canUse || listing.isEquipped ? 1 : 0.7)
        }
        .padding(10)
        .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(PaguroTheme.ink, lineWidth: 1.2)
        )
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

    private func spriteScale(for pet: PaguroPet) -> CGFloat {
        let growthScale = 0.88 + CGFloat(pet.growth) / 360
        let moodScale: CGFloat = pet.mood == .charged ? 1.04 : 1
        return growthScale * moodScale
    }

    private func foodCount(for pet: PaguroPet) -> Int {
        FoodKind.allCases.reduce(into: 0) { partialResult, food in
            partialResult += pet.inventory.count(for: food)
        }
    }

    private func bubble(size: CGFloat, opacity: Double) -> some View {
        Circle()
            .fill(.white.opacity(opacity))
            .frame(width: size, height: size)
    }

    private func metricCard(title: String, value: String, tint: Color, foreground: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(foreground.opacity(0.65))

            Text(value)
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundStyle(foreground)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(tint, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(PaguroTheme.ink, lineWidth: 1.5)
        )
    }

    private func progressCard(title: String, value: Int, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(PaguroTheme.ink)

                Spacer()

                Text("\(value)%")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(PaguroTheme.ink.opacity(0.7))
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.75))

                    Capsule()
                        .fill(tint)
                        .frame(width: proxy.size.width * (CGFloat(value) / 100))
                }
                .overlay(
                    Capsule()
                        .stroke(PaguroTheme.ink, lineWidth: 1.4)
                )
            }
            .frame(height: 14)
        }
        .padding(10)
        .background(PaguroTheme.cream.opacity(0.92), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(PaguroTheme.ink, lineWidth: 1.5)
        )
    }

    private func actionButton(
        title: String,
        subtitle: String,
        tint: Color,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundStyle(PaguroTheme.ink.opacity(0.7))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(tint, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(PaguroTheme.ink, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.72)
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [PaguroTheme.cream, Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack {
                RoundedRectangle(cornerRadius: 0)
                    .fill(PaguroTheme.lilac.opacity(0.45))
                    .frame(height: 52)
                    .offset(y: -26)
                Spacer()
                RoundedRectangle(cornerRadius: 0)
                    .fill(PaguroTheme.lilac.opacity(0.3))
                    .frame(height: 48)
                    .offset(y: 24)
            }
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
