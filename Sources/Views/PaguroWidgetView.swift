import SwiftUI

struct PaguroWidgetView: View {
    @EnvironmentObject private var store: PaguroStore
    @State private var panelMode: InventoryPanelMode = .shop

    private let statusWidth: CGFloat = 154
    private let marketWidth: CGFloat = 184
    private let windowHeight: CGFloat = 344

    private let itemColumns = [
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6),
    ]

    var body: some View {
        let pet = store.activePet

        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                titleBanner
                providerStrip
                petDock
                osWindow(for: pet)
                    .padding(.top, 14)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
        .background(background)
    }

    private var titleBanner: some View {
        VStack(spacing: 3) {
            HStack(spacing: 6) {
                Text("PAGURO")
                Text("✦")
                    .foregroundStyle(PaguroTheme.white)
                    .shadow(color: PaguroTheme.rose, radius: 0, x: 2, y: 2)
                Text("OS")
            }
            .font(PaguroTheme.displayFont(size: 18))
            .foregroundStyle(PaguroTheme.rose)
            .shadow(color: PaguroTheme.darkRose, radius: 0, x: 2, y: 2)
            .textCase(.uppercase)
            .lineLimit(1)
            .minimumScaleFactor(0.7)

            Text("desktop pet edition")
                .font(PaguroTheme.displayFont(size: 8))
                .foregroundStyle(PaguroTheme.rose)
                .lineLimit(1)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(PaguroTheme.cream)
                .overlay(
                    Rectangle()
                        .stroke(PaguroTheme.rose, lineWidth: 2)
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
        .padding(.bottom, 2)
    }

    private var providerStrip: some View {
        HStack(spacing: 6) {
            ForEach(ProviderKind.allCases) { provider in
                Button {
                    store.select(provider)
                } label: {
                    Text(provider.displayName.uppercased())
                        .font(PaguroTheme.uiFont(size: 15, weight: .bold))
                        .foregroundStyle(store.selectedProvider == provider ? PaguroTheme.white : PaguroTheme.outline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            Rectangle()
                                .fill(store.selectedProvider == provider ? PaguroTheme.rose : PaguroTheme.white)
                        )
                        .overlay(
                            Rectangle()
                                .stroke(PaguroTheme.outline, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var petDock: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(store.providerPets(for: store.selectedProvider)) { pet in
                    Button {
                        store.selectPet(pet.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 5) {
                                Rectangle()
                                    .fill(pet.mood == .charged ? PaguroTheme.gold : PaguroTheme.rose)
                                    .frame(width: 8, height: 8)

                                Text(pet.name)
                                    .font(PaguroTheme.uiFont(size: 17, weight: .bold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                            }

                            Text("\(pet.stage.displayName) / \(pet.weightText)")
                                .font(PaguroTheme.uiFont(size: 13, weight: .bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                        .foregroundStyle(PaguroTheme.outline)
                        .frame(width: 144, alignment: .leading)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 7)
                        .background(store.isSelectedPet(pet) ? PaguroTheme.cream : PaguroTheme.white)
                        .overlay(
                            Rectangle()
                                .stroke(PaguroTheme.outline, lineWidth: store.isSelectedPet(pet) ? 2.5 : 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 1)
        }
    }

    private func osWindow(for pet: PaguroPet) -> some View {
        HStack(alignment: .top, spacing: 10) {
            statusPanel(for: pet)
                .frame(width: statusWidth, height: windowHeight)

            terrariumPanel(for: pet)
                .frame(maxWidth: .infinity, minHeight: windowHeight, maxHeight: windowHeight, alignment: .top)

            marketPanel(for: pet)
                .frame(width: marketWidth, height: windowHeight)
        }
        .padding(10)
        .background(
            Rectangle()
                .fill(PaguroTheme.lilac)
                .offset(x: 4, y: 4)
        )
        .background(PaguroTheme.white)
        .overlay(
            Rectangle()
                .stroke(PaguroTheme.outline, lineWidth: 3)
        )
        .overlay(alignment: .topLeading) { cornerDecoration }
        .overlay(alignment: .topTrailing) { cornerDecoration }
        .overlay(alignment: .bottomLeading) { cornerDecoration }
        .overlay(alignment: .bottomTrailing) { cornerDecoration }
    }

    private func statusPanel(for pet: PaguroPet) -> some View {
        pixelPanel(
            title: "STATUS",
            headerFill: PaguroTheme.rose,
            headerForeground: PaguroTheme.white
        ) {
            VStack(spacing: 9) {
                statRow(label: "Name", value: pet.name)
                statRow(label: "Stage", value: pet.stage.displayName)
                statRow(label: "Weight", value: pet.weightText)

                pixelProgress(title: "Fullness", value: pet.fullness, fill: PaguroTheme.leaf)
                pixelProgress(title: "Growth", value: pet.growth, fill: PaguroTheme.lilac)

                VStack(spacing: 8) {
                    Text("+ \(pet.energy.formatted())")
                        .font(PaguroTheme.displayFont(size: 10))
                        .foregroundStyle(PaguroTheme.gold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(PaguroTheme.outline)
                        .overlay(
                            Rectangle()
                                .stroke(PaguroTheme.outline, lineWidth: 2)
                        )

                    Button {
                        store.refreshSelectedProviderTelemetry()
                    } label: {
                        VStack(spacing: 2) {
                            Text(store.selectedProvider == .claude ? "SYNC CLAUDE" : "PULSE DEMO")
                                .font(PaguroTheme.displayFont(size: 8))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)

                            Text(shortActionSubtitle)
                                .font(PaguroTheme.uiFont(size: 11, weight: .bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                        .foregroundStyle(PaguroTheme.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(PaguroTheme.rose)
                        .overlay(
                            Rectangle()
                                .stroke(PaguroTheme.outline, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)

                    VStack(spacing: 2) {
                        Text(store.selectedProviderActivityLabel.uppercased())
                            .font(PaguroTheme.uiFont(size: 10, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)

                        Text(store.selectedProviderUsageSummary)
                            .font(PaguroTheme.uiFont(size: 11, weight: .bold))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .foregroundStyle(PaguroTheme.outline)
                }
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(PaguroTheme.lilac)
                .overlay(
                    Rectangle()
                        .stroke(PaguroTheme.outline, lineWidth: 2)
                )
            }
        }
    }

    private func terrariumPanel(for pet: PaguroPet) -> some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(PaguroTheme.water)
                    .overlay(alignment: .bottom) {
                        screenFloor
                    }
                    .overlay(
                        Rectangle()
                            .stroke(PaguroTheme.outline, lineWidth: 3)
                    )
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(PaguroTheme.white.opacity(0.25))
                            .frame(height: 8)
                    }

                PixelPetSpriteView(pet: pet)
                    .frame(width: 108, height: 108)
                    .padding(.bottom, 24)
                    .scaleEffect(pet.mood == .charged ? 1.04 : 1)
                    .animation(.easeInOut(duration: 0.18), value: pet.mood)
                    .animation(.easeInOut(duration: 0.18), value: pet.pattern)
                    .animation(.easeInOut(duration: 0.18), value: pet.shell)
            }
            .frame(height: 220)

            HStack(spacing: 8) {
                pillButton(title: store.selectedProvider == .claude ? "sync" : "pulse") {
                    store.refreshSelectedProviderTelemetry()
                }

                pillButton(title: "play", isEnabled: pet.energy >= 30) {
                    store.playWithActivePet()
                }
            }
        }
        .padding(8)
        .background(PaguroTheme.white)
        .overlay(
            Rectangle()
                .stroke(PaguroTheme.outline, lineWidth: 3)
        )
    }

    private var screenFloor: some View {
        GeometryReader { _ in
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(PaguroTheme.sand)

                Canvas { context, size in
                    let dotSpacing: CGFloat = 12
                    for x in stride(from: 4 as CGFloat, through: size.width, by: dotSpacing) {
                        for y in stride(from: 5 as CGFloat, through: size.height, by: dotSpacing) {
                            context.fill(
                                Path(CGRect(x: x, y: y, width: 2, height: 2)),
                                with: .color(PaguroTheme.outline.opacity(0.55))
                            )
                        }
                    }
                }

                Rectangle()
                    .fill(PaguroTheme.outline)
                    .frame(height: 2)
            }
        }
        .frame(height: 68)
    }

    private func marketPanel(for pet: PaguroPet) -> some View {
        pixelPanel(
            title: panelMode == .shop ? "MARKET" : "BAG",
            headerFill: PaguroTheme.lilac,
            headerForeground: PaguroTheme.outline
        ) {
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    tabButton(for: .shop)
                    tabButton(for: .bag)
                }

                LazyVGrid(columns: itemColumns, spacing: 6) {
                    if panelMode == .shop {
                        ForEach(store.activeShopListings) { listing in
                            shopSlot(for: listing)
                        }

                        ForEach(0..<max(0, 9 - store.activeShopListings.count), id: \.self) { _ in
                            emptySlot
                        }
                    } else {
                        let bagListings = store.activeBagListings

                        ForEach(bagListings) { listing in
                            bagSlot(for: listing)
                        }

                        ForEach(0..<max(0, 9 - bagListings.count), id: \.self) { _ in
                            emptySlot
                        }
                    }
                }

                Text(panelMode == .shop ? "food, shells, eggs" : "feed, equip, hatch")
                    .font(PaguroTheme.uiFont(size: 12, weight: .bold))
                    .foregroundStyle(PaguroTheme.outline.opacity(0.78))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                HStack(spacing: 4) {
                    inventoryTicker(label: "Shells", value: "\(pet.inventory.ownedShells.count)")
                    inventoryTicker(label: "Food", value: "\(foodCount(for: pet))")
                    inventoryTicker(label: "Eggs", value: "\(pet.inventory.eggs)")
                }
            }
        }
    }

    private func tabButton(for mode: InventoryPanelMode) -> some View {
        Button {
            panelMode = mode
        } label: {
            Text(mode.displayName)
                .font(PaguroTheme.uiFont(size: 15, weight: .bold))
                .foregroundStyle(PaguroTheme.outline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(panelMode == mode ? PaguroTheme.white : PaguroTheme.gray)
                .overlay(
                    Rectangle()
                        .stroke(PaguroTheme.outline, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }

    private func shopSlot(for listing: ShopListing) -> some View {
        let disabled = listing.isOwned || !listing.isAffordable

        return itemSlot(
            icon: iconKind(for: listing.kind),
            badge: listing.badge,
            disabled: disabled,
            fill: disabled ? PaguroTheme.cream : PaguroTheme.white,
            action: { store.buyShopItem(listing.kind) }
        )
        .help("\(listing.title) · \(listing.detail)")
    }

    private func bagSlot(for listing: BagListing) -> some View {
        let disabled = listing.isEquipped

        return itemSlot(
            icon: iconKind(for: listing.kind),
            badge: listing.badge,
            disabled: disabled,
            fill: disabled ? PaguroTheme.gray : PaguroTheme.white,
            action: { store.useBagItem(listing.kind) }
        )
        .help("\(listing.title) · \(listing.detail)")
    }

    private func itemSlot(
        icon: PixelIconKind,
        badge: String,
        disabled: Bool,
        fill: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack(alignment: .bottomTrailing) {
                Rectangle()
                    .fill(fill)
                    .overlay(
                        Rectangle()
                            .stroke(disabled ? PaguroTheme.gray : PaguroTheme.lilac, style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                    )

                PixelInventoryIconView(kind: icon)
                    .padding(10)

                Text(badge.uppercased())
                    .font(PaguroTheme.uiFont(size: 11, weight: .bold))
                    .foregroundStyle(PaguroTheme.gold)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 3)
                    .background(PaguroTheme.outline)
                    .overlay(
                        Rectangle()
                            .stroke(PaguroTheme.white, lineWidth: 1.5)
                    )
                    .offset(x: 3, y: 3)
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .opacity(disabled ? 0.72 : 1)
    }

    private var emptySlot: some View {
        Rectangle()
            .fill(PaguroTheme.gray)
            .overlay(
                Rectangle()
                    .stroke(PaguroTheme.gray, lineWidth: 2)
            )
            .aspectRatio(1, contentMode: .fit)
    }

    private func inventoryTicker(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(PaguroTheme.uiFont(size: 10, weight: .bold))
                .textCase(.uppercase)
                .lineLimit(1)

            Text(value)
                .font(PaguroTheme.uiFont(size: 14, weight: .bold))
        }
        .foregroundStyle(PaguroTheme.outline)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(PaguroTheme.white)
        .overlay(
            Rectangle()
                .stroke(PaguroTheme.outline, lineWidth: 2)
        )
    }

    private func pixelPanel<Content: View>(
        title: String,
        headerFill: Color,
        headerForeground: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack(alignment: .top) {
            PaguroTheme.cream

            VStack(spacing: 0) {
                Color.clear
                    .frame(height: 14)

                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .padding(8)

            Text(title)
                .font(PaguroTheme.displayFont(size: 9))
                .foregroundStyle(headerForeground)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(headerFill)
                .overlay(
                    Rectangle()
                        .stroke(PaguroTheme.outline, lineWidth: 2)
                )
                .offset(y: -6)
        }
        .overlay(
            Rectangle()
                .stroke(PaguroTheme.outline, lineWidth: 3)
        )
        .overlay(alignment: .topLeading) { cornerDecoration }
        .overlay(alignment: .topTrailing) { cornerDecoration }
        .overlay(alignment: .bottomLeading) { cornerDecoration }
        .overlay(alignment: .bottomTrailing) { cornerDecoration }
    }

    private func statRow(label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("\(label):")
                .font(PaguroTheme.uiFont(size: 16, weight: .bold))

            Spacer(minLength: 6)

            Text(value)
                .font(PaguroTheme.uiFont(size: 17, weight: .bold))
                .foregroundStyle(PaguroTheme.rose)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .foregroundStyle(PaguroTheme.outline)
        .padding(.bottom, 4)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(PaguroTheme.rose)
                .frame(height: 2)
        }
    }

    private func pixelProgress(title: String, value: Int, fill: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(PaguroTheme.uiFont(size: 15, weight: .bold))
                .foregroundStyle(PaguroTheme.outline)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(PaguroTheme.white)

                    Rectangle()
                        .fill(fill)
                        .frame(width: proxy.size.width * (CGFloat(value) / 100))

                    HStack(spacing: 0) {
                        ForEach(0..<12, id: \.self) { _ in
                            Rectangle()
                                .fill(PaguroTheme.outline.opacity(0.18))
                                .frame(width: 1)
                            Spacer(minLength: 0)
                        }
                    }
                    .padding(.horizontal, 6)
                }
                .overlay(
                    Rectangle()
                        .stroke(PaguroTheme.outline, lineWidth: 2)
                )
            }
            .frame(height: 14)
        }
    }

    private func pillButton(title: String, isEnabled: Bool = true, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(PaguroTheme.uiFont(size: 16, weight: .bold))
                .foregroundStyle(PaguroTheme.white)
                .textCase(.lowercase)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isEnabled ? PaguroTheme.rose : PaguroTheme.gray)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(PaguroTheme.outline, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.76)
    }

    private var shortActionSubtitle: String {
        switch store.selectedProvider {
        case .claude:
            return "live energy"
        case .openAI:
            return "demo energy"
        }
    }

    private var cornerDecoration: some View {
        Rectangle()
            .fill(PaguroTheme.rose)
            .frame(width: 8, height: 8)
    }

    private var background: some View {
        GeometryReader { proxy in
            ZStack {
                PaguroTheme.white

                Canvas { context, size in
                    let spacing: CGFloat = 24
                    for x in stride(from: 8 as CGFloat, through: size.width, by: spacing) {
                        for y in stride(from: 8 as CGFloat, through: size.height, by: spacing) {
                            context.fill(
                                Path(ellipseIn: CGRect(x: x, y: y, width: 4, height: 4)),
                                with: .color(PaguroTheme.dot)
                            )
                        }
                    }
                }

                Rectangle()
                    .fill(PaguroTheme.lilac)
                    .frame(width: proxy.size.width * 1.4, height: 72)
                    .rotationEffect(.degrees(-3))
                    .offset(y: -proxy.size.height * 0.36)

                Rectangle()
                    .fill(PaguroTheme.lilac)
                    .frame(width: proxy.size.width * 1.4, height: 72)
                    .rotationEffect(.degrees(-3))
                    .offset(y: proxy.size.height * 0.38)
            }
            .ignoresSafeArea()
        }
    }

    private func foodCount(for pet: PaguroPet) -> Int {
        FoodKind.allCases.reduce(into: 0) { partialResult, food in
            partialResult += pet.inventory.count(for: food)
        }
    }

    private func iconKind(for kind: ShopItemKind) -> PixelIconKind {
        switch kind {
        case .food(let food):
            return iconKind(for: food)
        case .shell(let shell):
            return .shell(shell)
        case .egg:
            return .egg
        }
    }

    private func iconKind(for kind: BagItemKind) -> PixelIconKind {
        switch kind {
        case .food(let food):
            return iconKind(for: food)
        case .shell(let shell):
            return .shell(shell)
        case .egg:
            return .egg
        }
    }

    private func iconKind(for food: FoodKind) -> PixelIconKind {
        switch food {
        case .berryBits:
            return .berry
        case .kelpCrunch:
            return .kelp
        case .sunMorsel:
            return .sun
        }
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

private enum PixelIconKind {
    case berry
    case kelp
    case sun
    case shell(ShellVariant)
    case egg
}

private struct PixelInventoryIconView: View {
    let kind: PixelIconKind

    var body: some View {
        PixelGlyphView(blocks: blocks, gridSize: 16)
    }

    private var blocks: [PixelBlock] {
        switch kind {
        case .berry:
            return [
                .init(6, 1, 2, 1, PaguroTheme.leaf),
                .init(5, 2, 4, 1, PaguroTheme.leaf),
                .init(4, 4, 6, 6, PaguroTheme.outline),
                .init(5, 5, 4, 4, PaguroTheme.rose),
                .init(6, 10, 2, 1, PaguroTheme.rose),
                .init(5, 6, 1, 1, PaguroTheme.white),
                .init(8, 7, 1, 1, PaguroTheme.white),
                .init(6, 8, 1, 1, PaguroTheme.white),
            ]
        case .kelp:
            return [
                .init(6, 2, 1, 10, PaguroTheme.leaf),
                .init(7, 1, 1, 11, PaguroTheme.leaf),
                .init(8, 3, 1, 8, PaguroTheme.leaf),
                .init(5, 4, 1, 2, PaguroTheme.outline),
                .init(9, 5, 1, 2, PaguroTheme.outline),
                .init(4, 7, 2, 1, PaguroTheme.outline),
                .init(8, 8, 2, 1, PaguroTheme.outline),
            ]
        case .sun:
            return [
                .init(6, 3, 4, 4, PaguroTheme.outline),
                .init(7, 4, 2, 2, PaguroTheme.gold),
                .init(7, 1, 2, 2, PaguroTheme.gold),
                .init(7, 7, 2, 2, PaguroTheme.gold),
                .init(4, 4, 2, 2, PaguroTheme.gold),
                .init(10, 4, 2, 2, PaguroTheme.gold),
                .init(5, 2, 1, 1, PaguroTheme.gold),
                .init(10, 2, 1, 1, PaguroTheme.gold),
                .init(5, 8, 1, 1, PaguroTheme.gold),
                .init(10, 8, 1, 1, PaguroTheme.gold),
            ]
        case .shell(let shell):
            let base = shellBase(shell)
            let accent = shellAccent(shell)
            return [
                .init(6, 2, 4, 1, PaguroTheme.outline),
                .init(5, 3, 6, 1, PaguroTheme.outline),
                .init(4, 4, 8, 1, PaguroTheme.outline),
                .init(4, 5, 8, 1, PaguroTheme.outline),
                .init(3, 6, 8, 1, PaguroTheme.outline),
                .init(3, 7, 7, 1, PaguroTheme.outline),
                .init(4, 8, 5, 1, PaguroTheme.outline),
                .init(6, 3, 3, 1, base),
                .init(5, 4, 5, 1, base),
                .init(5, 5, 5, 1, base),
                .init(4, 6, 5, 1, base),
                .init(4, 7, 4, 1, base),
                .init(7, 4, 1, 1, accent),
                .init(8, 5, 1, 2, accent),
                .init(6, 6, 1, 2, accent),
            ]
        case .egg:
            return [
                .init(5, 2, 4, 1, PaguroTheme.outline),
                .init(4, 3, 6, 1, PaguroTheme.outline),
                .init(4, 4, 6, 1, PaguroTheme.outline),
                .init(3, 5, 8, 1, PaguroTheme.outline),
                .init(3, 6, 8, 2, PaguroTheme.outline),
                .init(4, 8, 6, 2, PaguroTheme.outline),
                .init(5, 10, 4, 1, PaguroTheme.outline),
                .init(5, 3, 4, 1, PaguroTheme.white),
                .init(5, 4, 4, 1, PaguroTheme.white),
                .init(4, 5, 6, 3, PaguroTheme.white),
                .init(5, 8, 4, 2, PaguroTheme.white),
                .init(6, 4, 1, 1, PaguroTheme.rose),
                .init(4, 7, 1, 1, PaguroTheme.rose),
                .init(8, 8, 1, 1, PaguroTheme.rose),
            ]
        }
    }

    private func shellBase(_ shell: ShellVariant) -> Color {
        switch shell {
        case .sand:
            return PaguroTheme.sand
        case .sunset:
            return PaguroTheme.cream
        case .lagoon:
            return PaguroTheme.white
        }
    }

    private func shellAccent(_ shell: ShellVariant) -> Color {
        switch shell {
        case .sand:
            return PaguroTheme.sandDark
        case .sunset:
            return PaguroTheme.rose
        case .lagoon:
            return PaguroTheme.water
        }
    }
}

private struct PixelPetSpriteView: View {
    let pet: PaguroPet

    var body: some View {
        ZStack(alignment: .bottom) {
            PixelGlyphView(blocks: shadowBlocks, gridSize: 16)
            PixelGlyphView(blocks: spriteBlocks, gridSize: 16)
                .offset(y: -8)
        }
    }

    private var spriteBlocks: [PixelBlock] {
        let shellBase = shellBaseColor
        let shellAccent = shellAccentColor
        let body = bodyColor
        let bodyAccent = bodyColor.opacity(0.78)

        return [
            .init(9, 1, 4, 1, PaguroTheme.outline),
            .init(8, 2, 6, 1, PaguroTheme.outline),
            .init(7, 3, 7, 1, PaguroTheme.outline),
            .init(7, 4, 8, 1, PaguroTheme.outline),
            .init(6, 5, 8, 1, PaguroTheme.outline),
            .init(6, 6, 7, 1, PaguroTheme.outline),
            .init(7, 7, 5, 1, PaguroTheme.outline),
            .init(9, 2, 3, 1, shellBase),
            .init(8, 3, 5, 1, shellBase),
            .init(8, 4, 6, 1, shellBase),
            .init(7, 5, 6, 1, shellBase),
            .init(7, 6, 5, 1, shellBase),
            .init(10, 3, 1, 1, shellAccent),
            .init(11, 4, 1, 2, shellAccent),
            .init(9, 5, 1, 2, shellAccent),
            .init(2, 10, 3, 1, PaguroTheme.outline),
            .init(1, 9, 2, 1, PaguroTheme.outline),
            .init(4, 11, 2, 1, PaguroTheme.outline),
            .init(2, 11, 2, 1, body),
            .init(4, 10, 1, 1, body),
            .init(4, 8, 1, 3, PaguroTheme.outline),
            .init(6, 9, 1, 2, PaguroTheme.outline),
            .init(3, 7, 2, 2, PaguroTheme.white),
            .init(5, 8, 2, 2, PaguroTheme.white),
            .init(4, 8, 1, 1, PaguroTheme.outline),
            .init(6, 9, 1, 1, PaguroTheme.outline),
            .init(4, 12, 3, 1, body),
            .init(5, 13, 2, 1, bodyAccent),
            .init(5, 14, 1, 1, PaguroTheme.outline),
            .init(7, 13, 1, 1, PaguroTheme.outline),
        ] + patternBlocks(bodyAccent: bodyAccent)
    }

    private var shadowBlocks: [PixelBlock] {
        [
            .init(4, 14, 6, 1, PaguroTheme.outline.opacity(0.2)),
            .init(5, 15, 4, 1, PaguroTheme.outline.opacity(0.2)),
        ]
    }

    private var bodyColor: Color {
        Color(hue: pet.bodyHue / 360, saturation: 0.72, brightness: 0.98)
    }

    private var shellBaseColor: Color {
        switch pet.shell {
        case .sand:
            return PaguroTheme.sand
        case .sunset:
            return PaguroTheme.cream
        case .lagoon:
            return PaguroTheme.white
        }
    }

    private var shellAccentColor: Color {
        switch pet.shell {
        case .sand:
            return PaguroTheme.sandDark
        case .sunset:
            return PaguroTheme.rose
        case .lagoon:
            return PaguroTheme.water
        }
    }

    private func patternBlocks(bodyAccent: Color) -> [PixelBlock] {
        switch pet.pattern {
        case .plain:
            return []
        case .speckles:
            return [
                .init(5, 12, 1, 1, bodyAccent),
                .init(6, 13, 1, 1, bodyAccent),
            ]
        case .stripes:
            return [
                .init(4, 12, 1, 2, bodyAccent),
                .init(6, 12, 1, 2, bodyAccent),
            ]
        }
    }
}

private struct PixelGlyphView: View {
    let blocks: [PixelBlock]
    let gridSize: Int

    var body: some View {
        GeometryReader { _ in
            Canvas { context, size in
                let unit = min(size.width, size.height) / CGFloat(gridSize)

                for block in blocks {
                    let rect = CGRect(
                        x: CGFloat(block.x) * unit,
                        y: CGFloat(block.y) * unit,
                        width: CGFloat(block.width) * unit,
                        height: CGFloat(block.height) * unit
                    )

                    context.fill(Path(rect), with: .color(block.color))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

private struct PixelBlock {
    let x: Int
    let y: Int
    let width: Int
    let height: Int
    let color: Color

    init(_ x: Int, _ y: Int, _ width: Int, _ height: Int, _ color: Color) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.color = color
    }
}
