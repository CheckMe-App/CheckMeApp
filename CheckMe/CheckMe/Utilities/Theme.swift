import SwiftUI
import UIKit

/// Shared colors and fonts for CheckMe ("Soft FIU" pastel palette).
/// Use these instead of hardcoded colors so every screen matches.
///
/// Text on colored cards and buttons should stay navy (Theme.textPrimary or Theme.onGold).
/// White text on pastels is too hard to read.
enum Theme {

    // MARK: - Colors

    /// Main text and headings (FIU navy)
    static let textPrimary = adaptive(light: (8, 30, 63), dark: (242, 244, 248))

    /// Subtitles, hints, finished tasks
    static let textSecondary = adaptive(light: (120, 130, 148), dark: (169, 180, 199))

    /// Text-only buttons and icons in the top bar, and the app's tint color
    static let primary = adaptive(light: (8, 30, 63), dark: (246, 227, 168))

    /// Butter gold: the + button, selected cards, checked circles
    static let gold = rgb(233, 196, 106)

    /// Text or icons sitting on top of gold
    static let onGold = rgb(8, 30, 63)

    /// Soft gold, for subtle highlights
    static let goldSoft = adaptive(light: (246, 227, 168), dark: (74, 65, 40))

    /// Powder blue, for secondary cards or icon tiles
    static let blueSoft = adaptive(light: (214, 228, 245), dark: (35, 52, 79))

    /// Screen background (light gray)
    static let background = adaptive(light: (245, 245, 243), dark: (14, 26, 46))

    /// Regular cards
    static let card = adaptive(light: (255, 255, 255), dark: (27, 42, 68))

    /// Small square behind icons on a white card
    static let iconTile = adaptive(light: (243, 243, 241), dark: (38, 56, 86))

    /// Soft shadow under cards
    static let shadow = Color.black.opacity(0.06)

    /// Streaks and badges
    static let accent = gold

    // MARK: - Fonts

    static let titleFont = Font.system(.largeTitle).weight(.bold)
    static let screenTitleFont = Font.system(.title).weight(.bold)
    static let headingFont = Font.system(.title3).weight(.semibold)
    static let bodyFont = Font.system(.body)
    static let captionFont = Font.system(.caption)
    static let sectionLabelFont = Font.system(.caption2).weight(.semibold)

    // MARK: - Helpers

    private static func rgb(_ r: Double, _ g: Double, _ b: Double) -> Color {
        Color(red: r / 255, green: g / 255, blue: b / 255)
    }

    private static func adaptive(light: (CGFloat, CGFloat, CGFloat),
                                 dark: (CGFloat, CGFloat, CGFloat)) -> Color {
        Color(UIColor { traits in
            let c = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: c.0 / 255, green: c.1 / 255, blue: c.2 / 255, alpha: 1)
        })
    }
}
