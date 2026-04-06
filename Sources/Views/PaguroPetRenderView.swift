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
            .init(11, 2, 5, 1, PaguroTheme.outline),
            .init(9, 3, 10, 1, PaguroTheme.outline),
            .init(8, 4, 12, 1, PaguroTheme.outline),
            .init(7, 5, 14, 1, PaguroTheme.outline),
            .init(6, 6, 15, 1, PaguroTheme.outline),
            .init(6, 7, 16, 1, PaguroTheme.outline),
            .init(5, 8, 17, 1, PaguroTheme.outline),
            .init(5, 9, 17, 1, PaguroTheme.outline),
            .init(5, 10, 16, 1, PaguroTheme.outline),
            .init(4, 11, 16, 1, PaguroTheme.outline),
            .init(4, 12, 15, 1, PaguroTheme.outline),
            .init(4, 13, 14, 1, PaguroTheme.outline),
            .init(5, 14, 12, 1, PaguroTheme.outline),
            .init(5, 15, 11, 1, PaguroTheme.outline),
            .init(6, 16, 9, 1, PaguroTheme.outline),
            .init(7, 17, 8, 1, PaguroTheme.outline),
            .init(8, 18, 6, 1, PaguroTheme.outline),
            .init(10, 19, 3, 1, PaguroTheme.outline),
            .init(11, 3, 5, 1, shellBase),
            .init(9, 4, 9, 1, shellBase),
            .init(8, 5, 11, 1, shellBase),
            .init(7, 6, 12, 1, shellBase),
            .init(7, 7, 13, 1, shellBase),
            .init(6, 8, 14, 1, shellBase),
            .init(6, 9, 14, 1, shellBase),
            .init(6, 10, 13, 1, shellBase),
            .init(5, 11, 13, 1, shellBase),
            .init(5, 12, 12, 1, shellBase),
            .init(5, 13, 11, 1, shellBase),
            .init(6, 14, 9, 1, shellBase),
            .init(6, 15, 8, 1, shellBase),
            .init(7, 16, 6, 1, shellBase),
            .init(8, 17, 5, 1, shellBase),
            .init(9, 18, 3, 1, shellBase),
        ]
    }

    private var shellHighlightBlocks: [PixelBlock] {
        [
            .init(10, 5, 2, 1, PaguroTheme.white.opacity(0.34)),
            .init(9, 6, 2, 1, PaguroTheme.white.opacity(0.32)),
            .init(8, 7, 2, 1, PaguroTheme.white.opacity(0.28)),
            .init(8, 8, 1, 2, PaguroTheme.white.opacity(0.24)),
        ]
    }

    private var shellTextureBlocks: [PixelBlock] {
        let accent = shellAccentColor

        return switch pet.shell {
        case .sand:
            [
                .init(13, 6, 2, 1, accent),
                .init(14, 7, 3, 1, accent),
                .init(11, 9, 4, 1, accent),
                .init(10, 11, 3, 2, accent),
                .init(13, 14, 2, 1, accent),
            ]
        case .sunset:
            [
                .init(9, 6, 7, 1, accent),
                .init(10, 9, 7, 1, accent),
                .init(11, 12, 5, 1, accent),
                .init(12, 15, 3, 1, accent),
            ]
        case .lagoon:
            [
                .init(12, 5, 2, 1, accent),
                .init(14, 7, 3, 1, accent),
                .init(9, 10, 5, 1, accent),
                .init(12, 13, 4, 1, accent),
                .init(10, 16, 2, 1, accent),
            ]
        }
    }

    private var shellOpeningUnderlayBlocks: [PixelBlock] {
        [
            .init(6, 12, 1, 4, PaguroTheme.white),
            .init(7, 13, 1, 3, PaguroTheme.white),
            .init(8, 14, 1, 2, PaguroTheme.white.opacity(0.9)),
            .init(8, 12, 1, 3, shellBaseColor.opacity(0.34)),
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
            .init(5, 11, 1, 6, PaguroTheme.outline),
            .init(6, 12, 1, 5, PaguroTheme.outline),
            .init(7, 13, 1, 3, PaguroTheme.outline.opacity(0.86)),
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
