import SwiftUI

enum Theme {
    static let background = Color(.systemBackground)
    static let cardSurface = Color(.secondarySystemBackground)
    static let cardSurfaceLight = Color(.tertiarySystemBackground)
    static let ringTrack = Color(.systemFill)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)

    // Posture quality palette
    static let good = Color(red: 0.20, green: 0.72, blue: 0.45)        // forest green
    static let borderline = Color(red: 1.00, green: 0.70, blue: 0.20)  // amber
    static let bad = Color(red: 0.95, green: 0.36, blue: 0.36)         // coral

    // Brand
    static let brandPrimary = Color(red: 0.36, green: 0.55, blue: 0.95)   // calm blue
    static let brandSecondary = Color(red: 0.55, green: 0.42, blue: 0.95) // soft purple
    static let streakFlame = Color(red: 1.00, green: 0.55, blue: 0.10)    // warm orange

    static let cardRadius: CGFloat = 20
    static let cardPadding: CGFloat = 20

    static var brandGradient: LinearGradient {
        LinearGradient(
            colors: [brandPrimary, brandSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func bigNumber(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func qualityColor(_ quality: PostureQuality) -> Color {
        switch quality {
        case .good: return good
        case .borderline: return borderline
        case .bad: return bad
        }
    }
}
