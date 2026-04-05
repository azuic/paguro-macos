import AppKit
import SwiftUI

enum PaguroTheme {
    static let white = Color(hex: 0xFFFFFF)
    static let dot = Color(hex: 0xEAE2F3)
    static let lilac = Color(hex: 0xD5C6F0)
    static let rose = Color(hex: 0xD94B73)
    static let darkRose = Color(hex: 0x9E2A4D)
    static let outline = Color(hex: 0x4A1525)
    static let cream = Color(hex: 0xFDEAE2)
    static let sand = Color(hex: 0xE8D5B7)
    static let sandDark = Color(hex: 0xD2B48C)
    static let water = Color(hex: 0x9AD2CB)
    static let gold = Color(hex: 0xF4C430)
    static let gray = Color(hex: 0xDCDCDC)
    static let leaf = Color(hex: 0x88C070)
    static let coral = Color(hex: 0xFF7F50)
    static let mint = leaf
    static let ink = outline
    static let lagoon = water
    static let peach = cream
    static let canvasTop = Color(hex: 0xFBF7F2)
    static let canvasBottom = Color(hex: 0xEEF7F6)
    static let card = Color(hex: 0xFFFFFF, opacity: 0.92)
    static let cardMuted = Color(hex: 0xF8F1EA)
    static let borderSoft = Color(hex: 0xE4D7C9)
    static let textPrimary = Color(hex: 0x352B31)
    static let textSecondary = Color(hex: 0x7D6E78)
    static let accent = Color(hex: 0xE1778B)
    static let accentSoft = Color(hex: 0xF7D9DF)
    static let seafoam = Color(hex: 0xB7E1DA)
    static let sandSoft = Color(hex: 0xECDDBF)
    static let success = Color(hex: 0x8BC489)

    static func displayFont(size: CGFloat) -> Font {
        if NSFont(name: "Press Start 2P", size: size) != nil {
            return .custom("Press Start 2P", size: size)
        }

        return .system(size: size, weight: .black, design: .monospaced)
    }

    static func uiFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if NSFont(name: "VT323", size: size) != nil {
            return .custom("VT323", size: size)
        }

        return .system(size: size, weight: weight, design: .monospaced)
    }

    static func titleFont(size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func bodyFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static func metaFont(size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

extension Color {
    init(hex: UInt, opacity: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
