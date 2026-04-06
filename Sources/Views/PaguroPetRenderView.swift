import AppKit
import SwiftUI

struct PaguroPetSpriteView: View {
    let pet: PaguroPet
    var pose: PaguroSpritePose = .idle
    var direction: PaguroSpriteDirection = .right
    var expression: PaguroSpriteExpression? = nil
    var isBlinking = false

    private var bodyTint: Color {
        Color(hue: pet.bodyHue / 360, saturation: 0.72, brightness: 0.96)
    }

    private var patternTint: Color {
        Color(hue: pet.bodyHue / 360, saturation: 0.78, brightness: 0.68)
    }

    private var activeExpression: PaguroSpriteExpression {
        expression ?? .from(mood: pet.mood)
    }

    var body: some View {
        ZStack {
            Ellipse()
                .fill(PaguroTheme.outline.opacity(0.14))
                .frame(width: 48, height: 10)
                .offset(x: 0, y: 33)

            SpriteLayerView(subdirectory: "Sprites/paguro/shell", name: pet.shell.assetName)
            SpriteLayerView(subdirectory: "Sprites/paguro/body", name: "body_fill_\(pose.assetSuffix)", tint: bodyTint)
            SpriteLayerView(subdirectory: "Sprites/paguro/body", name: "body_belly_\(pose.assetSuffix)")

            if let patternAssetName = pet.pattern.assetName {
                SpriteLayerView(
                    subdirectory: "Sprites/paguro/pattern",
                    name: patternAssetName,
                    tint: patternTint,
                    opacity: 0.82
                )
            }

            SpriteLayerView(subdirectory: "Sprites/paguro/body", name: "body_outline_\(pose.assetSuffix)")
            SpriteLayerView(subdirectory: "Sprites/paguro/face", name: isBlinking ? "eyes_blink" : "eyes_open")
            SpriteLayerView(subdirectory: "Sprites/paguro/face", name: activeExpression.assetName)
        }
        .frame(width: 96, height: 96)
        .scaleEffect(x: direction == .left ? -1 : 1, y: 1, anchor: .center)
    }
}

struct PaguroDesktopPetView: View {
    @EnvironmentObject private var store: PaguroStore
    @EnvironmentObject private var runtime: PaguroDesktopPetRuntime

    var body: some View {
        let pet = store.activePet
        let isBoosted = pet.lastUsagePulseAt != nil || pet.mood == .charged
        let isWalking = runtime.pose != .idle

        ZStack(alignment: .bottom) {
            PaguroPetSpriteView(
                pet: pet,
                pose: runtime.pose,
                direction: runtime.direction,
                expression: runtime.expression,
                isBlinking: runtime.isBlinking
            )
            .frame(width: 236, height: 236)
            .scaleEffect(isBoosted ? 1.04 : 1)
            .offset(y: isWalking ? -3 : 0)
            .animation(.easeInOut(duration: 0.14), value: runtime.pose)
            .animation(.easeInOut(duration: 0.18), value: runtime.isBlinking)
            .animation(.easeInOut(duration: 0.18), value: runtime.expression)
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

private struct SpriteLayerView: View {
    let subdirectory: String
    let name: String
    var tint: Color = .white
    var opacity: Double = 1

    var body: some View {
        Group {
            if let image = PaguroSpriteCatalog.image(name: name, subdirectory: subdirectory) {
                Image(nsImage: image)
                    .interpolation(.none)
                    .resizable()
                    .antialiased(false)
                    .aspectRatio(contentMode: .fit)
                    .colorMultiply(tint)
                    .opacity(opacity)
            } else {
                Color.clear
            }
        }
    }
}

@MainActor
private enum PaguroSpriteCatalog {
    private static var cache: [String: NSImage] = [:]

    static func image(name: String, subdirectory: String) -> NSImage? {
        let cacheKey = "\(subdirectory)/\(name)"
        if let cached = cache[cacheKey] {
            return cached
        }

        guard
            let url = Bundle.main.url(forResource: name, withExtension: "png"),
            let image = NSImage(contentsOf: url)
        else {
            return nil
        }

        cache[cacheKey] = image
        return image
    }
}

private extension ShellVariant {
    var assetName: String {
        switch self {
        case .sand:
            return "shell_sand"
        case .sunset:
            return "shell_sunset"
        case .lagoon:
            return "shell_lagoon"
        }
    }
}

private extension PetPattern {
    var assetName: String? {
        switch self {
        case .plain:
            return nil
        case .speckles:
            return "pattern_speckles"
        case .stripes:
            return "pattern_stripes"
        }
    }
}
