import SwiftUI
import AppKit

// MARK: - Color helpers

extension Color {
    public init(hex: UInt, alpha: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: alpha)
    }

    /// A color that resolves differently in light vs. dark appearance.
    public static func dynamic(light: Color, dark: Color) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            return NSColor(isDark ? dark : light)
        })
    }
}

// MARK: - "Graphite & Ember" design tokens

public enum Theme {
    // Accent
    public static let ember       = Color(hex: 0xE8742E)
    public static let emberText   = Color.dynamic(light: Color(hex: 0xC2591F), dark: Color(hex: 0xF08A48))
    public static let emberTint   = Color.dynamic(light: Color(hex: 0xE8742E, alpha: 0.13),
                                                  dark:  Color(hex: 0xE8742E, alpha: 0.16))

    // Surfaces
    public static let windowBG    = Color.dynamic(light: Color(hex: 0xF3F3F2), dark: Color(hex: 0x1C1C1B))
    public static let cardBG      = Color.dynamic(light: Color(hex: 0xFFFFFF), dark: Color(hex: 0xFFFFFF, alpha: 0.045))
    public static let fieldBG     = Color.dynamic(light: Color(hex: 0xFFFFFF), dark: Color(hex: 0xFFFFFF, alpha: 0.05))
    public static let buttonBG    = Color.dynamic(light: Color(hex: 0xFFFFFF), dark: Color(hex: 0xFFFFFF, alpha: 0.07))
    public static let checkboxOff = Color.dynamic(light: Color(hex: 0x000000, alpha: 0.10), dark: Color(hex: 0xFFFFFF, alpha: 0.11))

    // Lines
    public static let divider     = Color.dynamic(light: Color(hex: 0x000000, alpha: 0.07), dark: Color(hex: 0xFFFFFF, alpha: 0.08))
    public static let fieldBorder = Color.dynamic(light: Color(hex: 0x000000, alpha: 0.12), dark: Color(hex: 0xFFFFFF, alpha: 0.10))

    // Text
    public static let textPrimary   = Color.dynamic(light: Color(hex: 0x2C2C2A), dark: Color(hex: 0xE2E2DD))
    public static let textSecondary = Color.dynamic(light: Color(hex: 0x55554F), dark: Color(hex: 0xA3A39D))
    public static let textTertiary  = Color.dynamic(light: Color(hex: 0x8B8B85), dark: Color(hex: 0x87877F))
    public static let monoFaint     = Color.dynamic(light: Color(hex: 0x9A9A94), dark: Color(hex: 0x75756F))

    // Inverse (banner / logo squircle)
    public static let inversePanelBG = Color.dynamic(light: Color(hex: 0x1F1F1E), dark: Color(hex: 0x0F0F0E))
    public static let inverseText    = Color(hex: 0xC9C9C6)
    public static let squircleBG     = Color(hex: 0x1F1F1E)

    // Status
    public static let successText = Color.dynamic(light: Color(hex: 0x3D8A55), dark: Color(hex: 0x5CB87A))

    // Overlay pill (fixed dark in both modes)
    public static let overlayBG     = Color(hex: 0x161615, alpha: 0.94)
    public static let overlayBorder = Color(hex: 0xFFFFFF, alpha: 0.08)
    public static let overlayText   = Color(hex: 0xF0F0EC)
    public static let overlayDim    = Color(hex: 0x8A8A84)
}

// MARK: - Fonts

extension Font {
    /// SF Mono (ui-monospace) at the given size.
    public static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

// MARK: - Reusable text styles

/// Mono, uppercase, letter-spaced label (titlebars, tabs, section headers).
public struct MonoLabel: View {
    let text: String
    var size: CGFloat
    var weight: Font.Weight
    var tracking: CGFloat
    var color: Color

    public init(text: String, size: CGFloat = 11, weight: Font.Weight = .semibold,
                tracking: CGFloat = 0.6, color: Color = Theme.textSecondary) {
        self.text = text
        self.size = size
        self.weight = weight
        self.tracking = tracking
        self.color = color
    }

    public var body: some View {
        Text(text.uppercased())
            .font(.mono(size, weight: weight))
            .tracking(tracking)
            .foregroundStyle(color)
    }
}
