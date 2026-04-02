import SwiftUI

struct PaguroWidgetView: View {
    @EnvironmentObject private var store: PaguroStore

    var body: some View {
        let pet = store.activePet

        VStack(spacing: 14) {
            header(for: pet)
            providerPicker
            terrarium(for: pet)
            statGrid(for: pet)
            actions(for: pet)
        }
        .padding(14)
        .background(background)
    }

    private func header(for pet: PaguroPet) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Paguro")
                    .font(.system(size: 21, weight: .black, design: .rounded))
                    .foregroundStyle(PaguroTheme.rose)

                Text("\(pet.name) / \(pet.stage.displayName)")
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
            .scaleEffect(pet.mood == .charged ? 1.04 : 1)
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

                Capsule()
                    .fill(bodyTint)
                    .frame(width: 62, height: 42)
                    .overlay(
                        Capsule()
                            .stroke(PaguroTheme.ink, lineWidth: 3)
                    )

                HStack(spacing: 10) {
                    leg()
                    leg()
                    leg()
                }
                .offset(y: -4)
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
                metricCard(title: "Shell", value: pet.shell.displayName, tint: PaguroTheme.peach, foreground: PaguroTheme.ink)
            }

            progressCard(title: "Fullness", value: pet.fullness, tint: PaguroTheme.mint)
            progressCard(title: "Growth To Next Shell", value: pet.growth, tint: PaguroTheme.lilac)
        }
    }

    private func actions(for pet: PaguroPet) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                actionButton(title: "Pulse", subtitle: "Demo usage +", tint: PaguroTheme.rose) {
                    store.simulateUsagePulse()
                }

                actionButton(title: "Feed", subtitle: "-40 energy", tint: PaguroTheme.mint) {
                    store.feedActivePet()
                }
            }

            HStack(spacing: 8) {
                actionButton(title: "Play", subtitle: "-30 energy", tint: PaguroTheme.lilac) {
                    store.playWithActivePet()
                }

                actionButton(
                    title: "Shell",
                    subtitle: "\(pet.shell.next.displayName) / \(pet.shell.next.price)",
                    tint: PaguroTheme.peach
                ) {
                    store.buyNextShell()
                }
            }
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

    private func actionButton(title: String, subtitle: String, tint: Color, action: @escaping () -> Void) -> some View {
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
