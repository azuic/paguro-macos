import SwiftUI

struct PaguroPetSpriteView: View {
    let pet: PaguroPet
    var gridSize: Int = 16

    var body: some View {
        ZStack(alignment: .bottom) {
            PixelGlyphView(blocks: shadowBlocks, gridSize: gridSize)
            PixelGlyphView(blocks: shellBlocks, gridSize: gridSize)
            PixelGlyphView(blocks: bodyBlocks, gridSize: gridSize)
            PixelGlyphView(blocks: patternOverlayBlocks, gridSize: gridSize)
        }
    }

    private var shellBlocks: [PixelBlock] {
        let shellBase = shellBaseColor
        let shellAccent = shellAccentColor

        return [
            .init(8, 1, 5, 1, PaguroTheme.outline),
            .init(7, 2, 7, 1, PaguroTheme.outline),
            .init(6, 3, 9, 1, PaguroTheme.outline),
            .init(5, 4, 10, 1, PaguroTheme.outline),
            .init(4, 5, 12, 1, PaguroTheme.outline),
            .init(4, 6, 12, 1, PaguroTheme.outline),
            .init(4, 7, 11, 1, PaguroTheme.outline),
            .init(4, 8, 10, 1, PaguroTheme.outline),
            .init(5, 9, 10, 1, PaguroTheme.outline),
            .init(5, 10, 9, 1, PaguroTheme.outline),
            .init(6, 11, 8, 1, PaguroTheme.outline),
            .init(7, 12, 6, 1, PaguroTheme.outline),
            .init(8, 13, 6, 1, PaguroTheme.outline),
            .init(8, 14, 6, 1, PaguroTheme.outline),
            .init(8, 2, 4, 1, shellBase),
            .init(7, 3, 6, 1, shellBase),
            .init(6, 4, 8, 1, shellBase),
            .init(5, 5, 10, 1, shellBase),
            .init(5, 6, 10, 1, shellBase),
            .init(5, 7, 9, 1, shellBase),
            .init(5, 8, 8, 1, shellBase),
            .init(6, 9, 8, 1, shellBase),
            .init(6, 10, 7, 1, shellBase),
            .init(7, 11, 6, 1, shellBase),
            .init(8, 12, 4, 1, shellBase),
            .init(8, 13, 5, 1, shellBase),
            .init(9, 14, 4, 1, shellBase),
            .init(10, 4, 2, 1, shellAccent),
            .init(11, 5, 2, 2, shellAccent),
            .init(8, 6, 1, 3, shellAccent),
            .init(7, 8, 4, 1, shellAccent),
            .init(10, 9, 2, 2, shellAccent),
            .init(4, 7, 1, 4, PaguroTheme.outline),
            .init(5, 8, 1, 3, PaguroTheme.white),
            .init(4, 8, 1, 2, PaguroTheme.white),
        ]
    }

    private var bodyBlocks: [PixelBlock] {
        let body = bodyColor
        let bodyAccent = bodyColor.opacity(0.78)

        return [
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
            .init(4, 12, 4, 1, body),
            .init(5, 13, 3, 1, bodyAccent),
            .init(5, 14, 1, 1, PaguroTheme.outline),
            .init(7, 14, 1, 1, PaguroTheme.outline),
        ]
    }

    private var patternOverlayBlocks: [PixelBlock] {
        let bodyAccent = bodyColor.opacity(0.78)

        return switch pet.pattern {
        case .plain:
            []
        case .speckles:
            [
                .init(5, 12, 1, 1, bodyAccent),
                .init(6, 13, 1, 1, bodyAccent),
            ]
        case .stripes:
            [
                .init(4, 12, 1, 2, bodyAccent),
                .init(6, 12, 1, 2, bodyAccent),
            ]
        }
    }

    private var shadowBlocks: [PixelBlock] {
        [
            .init(3, 14, 8, 1, PaguroTheme.outline.opacity(0.16)),
            .init(4, 15, 6, 1, PaguroTheme.outline.opacity(0.16)),
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
}

struct PaguroDesktopPetView: View {
    @EnvironmentObject private var store: PaguroStore

    var body: some View {
        let pet = store.activePet
        let isBoosted = pet.lastUsagePulseAt != nil || pet.mood == .charged

        ZStack(alignment: .bottom) {
            PaguroPetSpriteView(pet: pet)
                .frame(width: 236, height: 236)
                .scaleEffect(isBoosted ? 1.04 : 1)
                .offset(y: isBoosted ? -6 : 0)
                .animation(.easeInOut(duration: 0.18), value: pet.shell)
                .animation(.easeInOut(duration: 0.18), value: pet.pattern)
                .animation(.easeInOut(duration: 0.18), value: pet.lastUsagePulseAt)
        }
        .frame(width: 248, height: 248, alignment: .bottom)
        .padding(.vertical, 6)
        .background(Color.clear)
        .allowsHitTesting(false)
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
