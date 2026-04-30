import UIKit

enum AppTheme {
    // MARK: - Palette
    enum Pigment {
        static let voidBlack     = UIColor(hex: "#0A0A0F")
        static let abyssNavy     = UIColor(hex: "#0D0D1A")
        static let cosmicPurple  = UIColor(hex: "#1A0A2E")
        static let nebulaViolet  = UIColor(hex: "#6C3FC5")
        static let prismaticBlue = UIColor(hex: "#3B82F6")
        static let auroraGreen   = UIColor(hex: "#10B981")
        static let solarGold     = UIColor(hex: "#F59E0B")
        static let novaRed       = UIColor(hex: "#EF4444")
        static let stellarPink   = UIColor(hex: "#EC4899")
        static let glacierWhite  = UIColor(hex: "#F8FAFC")
        static let mistGray      = UIColor(hex: "#94A3B8")
        static let obsidianCard  = UIColor(hex: "#13131F")
        static let crystalBorder = UIColor(hex: "#2A2A45")

        // Rarity colors
        static let ssrGold       = UIColor(hex: "#FFD700")
        static let srPurple      = UIColor(hex: "#B44FE8")
        static let rBlue         = UIColor(hex: "#4A9EFF")

        // Gradients
        static let gradientSSR   = [UIColor(hex: "#FFD700"), UIColor(hex: "#FF8C00")]
        static let gradientSR    = [UIColor(hex: "#B44FE8"), UIColor(hex: "#6C3FC5")]
        static let gradientR     = [UIColor(hex: "#4A9EFF"), UIColor(hex: "#3B82F6")]
        static let gradientHero  = [UIColor(hex: "#1A0A2E"), UIColor(hex: "#0D0D1A")]
        static let gradientAccent = [UIColor(hex: "#6C3FC5"), UIColor(hex: "#3B82F6")]
    }

    // MARK: - Typography
    enum Typeface {
        static func display(_ size: CGFloat) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: .black)
        }
        static func headline(_ size: CGFloat) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: .bold)
        }
        static func body(_ size: CGFloat) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: .medium)
        }
        static func caption(_ size: CGFloat) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: .regular)
        }
        static func mono(_ size: CGFloat) -> UIFont {
            UIFont.monospacedDigitSystemFont(ofSize: size, weight: .semibold)
        }
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat  = 4
        static let sm: CGFloat  = 8
        static let md: CGFloat  = 16
        static let lg: CGFloat  = 24
        static let xl: CGFloat  = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Radius
    enum Radius {
        static let sm: CGFloat  = 8
        static let md: CGFloat  = 12
        static let lg: CGFloat  = 16
        static let xl: CGFloat  = 24
        static let pill: CGFloat = 50
    }

    // MARK: - Gradient helpers
    static func applyGradient(to view: UIView, colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0, y: 0), endPoint: CGPoint = CGPoint(x: 1, y: 1)) {
        view.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        let grad = CAGradientLayer()
        grad.colors = colors.map { $0.cgColor }
        grad.startPoint = startPoint
        grad.endPoint = endPoint
        grad.frame = view.bounds
        view.layer.insertSublayer(grad, at: 0)
    }

    static func makeGradientImage(colors: [UIColor], size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                              colors: colors.map { $0.cgColor } as CFArray,
                              locations: nil)!
        ctx.drawLinearGradient(grad, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}

// MARK: - UIColor hex init
extension UIColor {
    convenience init(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if h.hasPrefix("#") { h.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = CGFloat((rgb >> 16) & 0xFF) / 255
        let g = CGFloat((rgb >> 8)  & 0xFF) / 255
        let b = CGFloat(rgb & 0xFF)          / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

// MARK: - Emoji-safe text rendering
private extension Character {
    var usesEmojiPresentation: Bool {
        if unicodeScalars.count > 1 {
            return unicodeScalars.contains(where: { $0.properties.isEmoji })
        }
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmojiPresentation
    }
}

enum EmojiTextRenderer {
    private static func emojiFont(for baseFont: UIFont) -> UIFont? {
        if let font = UIFont(name: "AppleColorEmoji", size: baseFont.pointSize) {
            return font
        }
        if let font = UIFont(name: "Apple Color Emoji", size: baseFont.pointSize) {
            return font
        }

        let descriptor = UIFontDescriptor(fontAttributes: [.family: "Apple Color Emoji"])
        let font = UIFont(descriptor: descriptor, size: baseFont.pointSize)
        return font.familyName == "Apple Color Emoji" ? font : nil
    }

    static func attributedString(_ text: String, font: UIFont, color: UIColor) -> NSAttributedString {
        let attributed = NSMutableAttributedString()

        for character in text {
            let string = String(character)
            let attributes: [NSAttributedString.Key: Any]

            if character.usesEmojiPresentation,
               let emojiFont = emojiFont(for: font) {
                attributes = [
                    .font: emojiFont,
                    .foregroundColor: color
                ]
            } else {
                attributes = [
                    .font: font,
                    .foregroundColor: color
                ]
            }

            attributed.append(NSAttributedString(string: string, attributes: attributes))
        }

        return attributed
    }
}

extension UILabel {
    func setEmojiSafeText(_ text: String, font: UIFont, color: UIColor) {
        self.font = font
        textColor = color
        attributedText = EmojiTextRenderer.attributedString(text, font: font, color: color)
    }
}

enum ReelSymbolArtwork {
    struct Style {
        let iconName: String
        let shortLabel: String
    }

    static func style(for identifier: String) -> Style {
        switch identifier {
        case "cherry": return .init(iconName: "circle.hexagongrid.fill", shortLabel: "CH")
        case "lemon": return .init(iconName: "sun.max.fill", shortLabel: "LM")
        case "orange": return .init(iconName: "circle.fill", shortLabel: "OR")
        case "grape": return .init(iconName: "aqi.medium", shortLabel: "GR")
        case "bell": return .init(iconName: "bell.fill", shortLabel: "BL")
        case "seven": return .init(iconName: "7.circle.fill", shortLabel: "7")
        case "wild": return .init(iconName: "star.fill", shortLabel: "WD")
        case "scatter": return .init(iconName: "diamond.fill", shortLabel: "SC")
        case "asteroid": return .init(iconName: "sparkle", shortLabel: "AS")
        case "planet": return .init(iconName: "globe.americas.fill", shortLabel: "PL")
        case "comet": return .init(iconName: "sparkles", shortLabel: "CM")
        case "rocket": return .init(iconName: "rocket.fill", shortLabel: "RK")
        case "star": return .init(iconName: "star.circle.fill", shortLabel: "ST")
        case "galaxy": return .init(iconName: "moon.stars.fill", shortLabel: "GX")
        case "ufo_wild": return .init(iconName: "airplane.circle.fill", shortLabel: "UF")
        case "blackhole": return .init(iconName: "circle.dashed.inset.filled", shortLabel: "BH")
        case "coin": return .init(iconName: "dollarsign.circle.fill", shortLabel: "CN")
        case "shield": return .init(iconName: "shield.fill", shortLabel: "SH")
        case "sword": return .init(iconName: "bolt.horizontal.fill", shortLabel: "SW")
        case "crown": return .init(iconName: "crown.fill", shortLabel: "CR")
        case "dragon": return .init(iconName: "flame.fill", shortLabel: "DG")
        case "phoenix": return .init(iconName: "bird.fill", shortLabel: "PX")
        case "crystal": return .init(iconName: "sparkles.rectangle.stack.fill", shortLabel: "CY")
        case "rune": return .init(iconName: "tornado", shortLabel: "RN")
        default: return .init(iconName: "circle.fill", shortLabel: String(identifier.prefix(2)).uppercased())
        }
    }

    static func image(for identifier: String, pointSize: CGFloat, weight: UIImage.SymbolWeight = .regular) -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        return UIImage(systemName: style(for: identifier).iconName, withConfiguration: config)
    }
}
