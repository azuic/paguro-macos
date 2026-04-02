import SwiftUI

enum PaguroTheme {
    static let ink = Color(hex: 0x3D2A26)
    static let rose = Color(hex: 0xD95A7A)
    static let lilac = Color(hex: 0xD9C8F0)
    static let cream = Color(hex: 0xFFF7ED)
    static let peach = Color(hex: 0xF8E0D0)
    static let sand = Color(hex: 0xE6CC9E)
    static let lagoon = Color(hex: 0xA8D8D0)
    static let mint = Color(hex: 0x95C87D)
    static let gold = Color(hex: 0xF4C430)
}

extension Color {
    init(hex: UInt, opacity: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
