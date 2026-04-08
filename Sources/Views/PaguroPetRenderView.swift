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

    private var showsSleepyDroop: Bool {
        pose == .idle && activeExpression == .sleepy
    }

    private var showsChargedPump: Bool {
        pet.lastUsagePulseAt != nil
    }

    private var usesAnimatedOverlays: Bool {
        pose != .idle || showsSleepyDroop || showsChargedPump
    }

    private var bodyFillName: String {
        guard usesAnimatedOverlays else {
            return "body_fill_\(pose.assetSuffix)"
        }

        return spriteName(
            preferred: "body_fill_core_\(pose.assetSuffix)",
            fallback: "body_fill_\(pose.assetSuffix)",
            subdirectory: "Sprites/paguro/body"
        )
    }

    private var bodyOutlineName: String {
        guard usesAnimatedOverlays else {
            return "body_outline_\(pose.assetSuffix)"
        }

        return spriteName(
            preferred: "body_outline_core_\(pose.assetSuffix)",
            fallback: "body_outline_\(pose.assetSuffix)",
            subdirectory: "Sprites/paguro/body"
        )
    }

    private var clawOffset: CGSize {
        if showsChargedPump {
            return CGSize(width: 0.5, height: -2.5)
        }

        switch pose {
        case .idle:
            return .zero
        case .walkA:
            return CGSize(width: -1.5, height: -1)
        case .walkB:
            return CGSize(width: 1, height: 0.5)
        }
    }

    private var clawRotation: Angle {
        if showsChargedPump {
            return .degrees(-9)
        }

        switch pose {
        case .idle:
            return .degrees(0)
        case .walkA:
            return .degrees(-4)
        case .walkB:
            return .degrees(3)
        }
    }

    private var headOffset: CGSize {
        if showsSleepyDroop {
            return CGSize(width: -0.5, height: isBlinking ? 3 : 2.5)
        }

        if isBlinking {
            return CGSize(width: 0, height: 1)
        }

        switch pose {
        case .idle:
            return .zero
        case .walkA:
            return CGSize(width: -0.5, height: -1)
        case .walkB:
            return CGSize(width: 0.5, height: 0)
        }
    }

    private var headRotation: Angle {
        if showsSleepyDroop {
            return .degrees(7)
        }

        switch pose {
        case .idle:
            return .degrees(0)
        case .walkA:
            return .degrees(-2.5)
        case .walkB:
            return .degrees(2)
        }
    }

    var body: some View {
        ZStack {
            Ellipse()
                .fill(PaguroTheme.outline.opacity(0.14))
                .frame(width: 48, height: 10)
                .offset(x: 0, y: 33)

            SpriteLayerView(subdirectory: "Sprites/paguro/shell", name: pet.shell.assetName)
            SpriteLayerView(subdirectory: "Sprites/paguro/body", name: bodyFillName, tint: bodyTint)
            SpriteLayerView(subdirectory: "Sprites/paguro/body", name: "body_belly_\(pose.assetSuffix)")

            if usesAnimatedOverlays {
                SpriteLayerView(subdirectory: "Sprites/paguro/claws", name: "claws_fill_\(pose.assetSuffix)", tint: bodyTint)
                    .offset(clawOffset)
                    .rotationEffect(clawRotation, anchor: UnitPoint(x: 0.38, y: 0.56))
                SpriteLayerView(subdirectory: "Sprites/paguro/head", name: "head_fill_\(pose.assetSuffix)", tint: bodyTint)
                    .offset(headOffset)
                    .rotationEffect(headRotation, anchor: UnitPoint(x: 0.46, y: 0.52))
            }

            if let patternAssetName = pet.pattern.assetName {
                SpriteLayerView(
                    subdirectory: "Sprites/paguro/pattern",
                    name: patternAssetName,
                    tint: patternTint,
                    opacity: 0.82
                )
            }

            SpriteLayerView(subdirectory: "Sprites/paguro/body", name: bodyOutlineName)
            if usesAnimatedOverlays {
                SpriteLayerView(subdirectory: "Sprites/paguro/claws", name: "claws_outline_\(pose.assetSuffix)")
                    .offset(clawOffset)
                    .rotationEffect(clawRotation, anchor: UnitPoint(x: 0.38, y: 0.56))
            }

            ZStack {
                if usesAnimatedOverlays {
                    SpriteLayerView(subdirectory: "Sprites/paguro/head", name: "head_outline_\(pose.assetSuffix)")
                }
                SpriteLayerView(subdirectory: "Sprites/paguro/face", name: isBlinking ? "eyes_blink" : "eyes_open")
                SpriteLayerView(subdirectory: "Sprites/paguro/face", name: activeExpression.assetName)
            }
            .offset(usesAnimatedOverlays ? headOffset : .zero)
            .rotationEffect(usesAnimatedOverlays ? headRotation : .degrees(0), anchor: UnitPoint(x: 0.46, y: 0.52))
        }
        .frame(width: 96, height: 96)
        .scaleEffect(x: direction == .left ? -1 : 1, y: 1, anchor: .center)
    }

    private func spriteName(preferred: String, fallback: String, subdirectory: String) -> String {
        PaguroSpriteCatalog.hasImage(name: preferred, subdirectory: subdirectory) ? preferred : fallback
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

    static func hasImage(name: String, subdirectory: String) -> Bool {
        image(name: name, subdirectory: subdirectory) != nil
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
