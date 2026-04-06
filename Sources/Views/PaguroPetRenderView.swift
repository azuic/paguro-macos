import SwiftUI

struct PaguroPetSpriteView: View {
    let pet: PaguroPet
    var gridSize: Int = 24

    var body: some View {
        ZStack(alignment: .bottom) {
            PixelGlyphView(blocks: shadowBlocks, gridSize: gridSize)
            PixelGlyphView(blocks: shellCoreBlocks, gridSize: gridSize)
            PixelGlyphView(blocks: shellHighlightBlocks, gridSize: gridSize)
            PixelGlyphView(blocks: shellTextureBlocks, gridSize: gridSize)
            PixelGlyphView(blocks: shellOpeningUnderlayBlocks, gridSize: gridSize)
            PixelGlyphView(blocks: bodyBlocks, gridSize: gridSize)
            PixelGlyphView(blocks: bodyPatternBlocks, gridSize: gridSize)
            PixelGlyphView(blocks: shellRimBlocks, gridSize: gridSize)
        }
    }

    private var shellCoreBlocks: [PixelBlock] {
        let shellBase = shellBaseColor

        return [
            .init(13, 2, 4, 1, PaguroTheme.outline),
            .init(11, 3, 8, 1, PaguroTheme.outline),
            .init(10, 4, 10, 1, PaguroTheme.outline),
            .init(9, 5, 12, 1, PaguroTheme.outline),
            .init(8, 6, 13, 1, PaguroTheme.outline),
            .init(8, 7, 14, 1, PaguroTheme.outline),
            .init(7, 8, 15, 1, PaguroTheme.outline),
            .init(7, 9, 15, 1, PaguroTheme.outline),
            .init(7, 10, 15, 1, PaguroTheme.outline),
            .init(6, 11, 15, 1, PaguroTheme.outline),
            .init(6, 12, 14, 1, PaguroTheme.outline),
            .init(6, 13, 13, 1, PaguroTheme.outline),
            .init(7, 14, 11, 1, PaguroTheme.outline),
            .init(7, 15, 10, 1, PaguroTheme.outline),
            .init(8, 16, 8, 1, PaguroTheme.outline),
            .init(9, 17, 6, 1, PaguroTheme.outline),
            .init(11, 18, 3, 1, PaguroTheme.outline),
            .init(13, 3, 4, 1, shellBase),
            .init(11, 4, 7, 1, shellBase),
            .init(10, 5, 9, 1, shellBase),
            .init(9, 6, 10, 1, shellBase),
            .init(9, 7, 11, 1, shellBase),
            .init(8, 8, 12, 1, shellBase),
            .init(8, 9, 12, 1, shellBase),
            .init(8, 10, 12, 1, shellBase),
            .init(7, 11, 12, 1, shellBase),
            .init(7, 12, 11, 1, shellBase),
            .init(7, 13, 10, 1, shellBase),
            .init(8, 14, 8, 1, shellBase),
            .init(8, 15, 7, 1, shellBase),
            .init(9, 16, 5, 1, shellBase),
            .init(10, 17, 3, 1, shellBase),
        ]
    }

    private var shellHighlightBlocks: [PixelBlock] {
        [
            .init(12, 4, 2, 1, PaguroTheme.white.opacity(0.34)),
            .init(11, 5, 2, 1, PaguroTheme.white.opacity(0.3)),
            .init(10, 6, 2, 1, PaguroTheme.white.opacity(0.26)),
            .init(10, 7, 1, 2, PaguroTheme.white.opacity(0.22)),
        ]
    }

    private var shellTextureBlocks: [PixelBlock] {
        let accent = shellAccentColor

        return switch pet.shell {
        case .sand:
            [
                .init(14, 5, 2, 1, accent),
                .init(15, 7, 2, 1, accent),
                .init(13, 9, 4, 1, accent),
                .init(11, 11, 4, 1, accent),
                .init(10, 13, 3, 1, accent),
            ]
        case .sunset:
            [
                .init(12, 5, 5, 1, accent),
                .init(13, 8, 5, 1, accent),
                .init(11, 11, 6, 1, accent),
                .init(10, 14, 4, 1, accent),
            ]
        case .lagoon:
            [
                .init(14, 5, 2, 1, accent),
                .init(13, 7, 3, 1, accent),
                .init(12, 10, 4, 1, accent),
                .init(10, 13, 4, 1, accent),
                .init(11, 16, 2, 1, accent),
            ]
        }
    }

    private var shellOpeningUnderlayBlocks: [PixelBlock] {
        [
            .init(7, 11, 2, 1, PaguroTheme.white),
            .init(7, 12, 3, 1, PaguroTheme.white),
            .init(7, 13, 3, 1, PaguroTheme.white.opacity(0.94)),
            .init(8, 14, 2, 1, PaguroTheme.white.opacity(0.88)),
            .init(9, 15, 1, 1, shellBaseColor.opacity(0.28)),
        ]
    }

    private var bodyBlocks: [PixelBlock] {
        let body = bodyColor
        let bodyAccent = bodyColor.opacity(0.82)

        return [
            .init(5, 12, 1, 4, PaguroTheme.outline),
            .init(4, 13, 1, 4, PaguroTheme.outline),
            .init(6, 14, 1, 3, PaguroTheme.outline),
            .init(3, 15, 1, 2, PaguroTheme.outline),
            .init(2, 16, 2, 1, PaguroTheme.outline),
            .init(1, 17, 3, 1, PaguroTheme.outline),
            .init(2, 18, 9, 1, PaguroTheme.outline),
            .init(3, 19, 10, 1, PaguroTheme.outline),
            .init(5, 20, 8, 1, PaguroTheme.outline),
            .init(6, 21, 1, 2, PaguroTheme.outline),
            .init(10, 21, 1, 2, PaguroTheme.outline),
            .init(5, 13, 1, 2, PaguroTheme.white),
            .init(4, 14, 1, 2, PaguroTheme.white),
            .init(6, 15, 1, 1, PaguroTheme.white),
            .init(3, 16, 1, 1, PaguroTheme.white),
            .init(2, 17, 1, 1, PaguroTheme.white),
            .init(3, 18, 7, 1, body),
            .init(4, 19, 8, 1, bodyAccent),
            .init(6, 20, 5, 1, body),
        ]
    }

    private var bodyPatternBlocks: [PixelBlock] {
        let bodyAccent = bodyColor.opacity(0.78)

        return switch pet.pattern {
        case .plain:
            []
        case .speckles:
            [
                .init(5, 18, 1, 1, bodyAccent),
                .init(8, 19, 1, 1, bodyAccent),
                .init(10, 18, 1, 1, bodyAccent),
            ]
        case .stripes:
            [
                .init(4, 18, 1, 2, bodyAccent),
                .init(7, 18, 1, 2, bodyAccent),
                .init(10, 18, 1, 2, bodyAccent),
            ]
        }
    }

    private var shellRimBlocks: [PixelBlock] {
        [
            .init(6, 10, 1, 5, PaguroTheme.outline),
            .init(7, 11, 1, 4, PaguroTheme.outline),
            .init(8, 12, 1, 2, PaguroTheme.outline.opacity(0.86)),
        ]
    }

    private var shadowBlocks: [PixelBlock] {
        [
            .init(4, 21, 12, 1, PaguroTheme.outline.opacity(0.16)),
            .init(5, 22, 10, 1, PaguroTheme.outline.opacity(0.11)),
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
