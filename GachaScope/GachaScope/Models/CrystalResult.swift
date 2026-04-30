import Foundation

enum Rarity: String, CaseIterable {
    case ssr = "SSR"
    case sr  = "SR"
    case r   = "R"

    var displayColor: String {
        switch self {
        case .ssr: return "#FFD700"
        case .sr:  return "#B44FE8"
        case .r:   return "#4A9EFF"
        }
    }
    var weight: Int {
        switch self {
        case .ssr: return 3
        case .sr:  return 2
        case .r:   return 1
        }
    }
}

struct GachaPull {
    let index: Int
    let rarity: Rarity
    let pityCountAtPull: Int
}

struct GachaResult {
    let totalPulls: Int
    let ssrCount: Int
    let srCount: Int
    let rCount: Int
    let pulls: [GachaPull]
    let ssrPullIndices: [Int]
    let longestSSRDrought: Int
    let shortestSSRStreak: Int
    let avgPullsPerSSR: Double
    let actualSSRRate: Double
    let actualSRRate: Double
    let theoreticalSSRRate: Double
    let theoreticalSRRate: Double
    let luckIndex: Double
    let badLuckIndex: Int
    let convergenceData: [(pulls: Int, rate: Double)]
}

struct ReelSymbol {
    let identifier: String
    let emoji: String
    let name: String
    var weight: Int
    var payout3: Double
    var payout2: Double
    var isWild: Bool
    var isScatter: Bool
}

struct ReelConfig {
    var symbols: [ReelSymbol]
    var scatterMinCount: Int = 2
    var scatterPayout: Double = 12.0

    var theoreticalRTP: Double {
        let total = symbols.reduce(0) { $0 + $1.weight }
        guard total > 0 else { return 0 }
        let W = Double(total)
        let wildP    = symbols.filter { $0.isWild    }.reduce(0.0) { $0 + Double($1.weight) / W }
        let scatterP = symbols.filter { $0.isScatter }.reduce(0.0) { $0 + Double($1.weight) / W }

        var rtp = 0.0
        rtp += (3 * scatterP * scatterP * (1 - scatterP) + pow(scatterP, 3)) * scatterPayout
        let topPay = symbols.filter { !$0.isWild && !$0.isScatter }.map { $0.payout3 }.max() ?? 0
        rtp += pow(wildP, 3) * topPay * 1.5
        for sym in symbols where !sym.isWild && !sym.isScatter {
            let p = Double(sym.weight) / W
            guard p > 0 else { continue }
            rtp += p * p * p * sym.payout3
            rtp += 3 * wildP * p * p * sym.payout3
            if sym.payout2 > 0 {
                let other = max(0, 1.0 - p - wildP - scatterP)
                rtp += 3 * p * p * other * sym.payout2
            }
        }
        return rtp
    }

    static func classicFruit() -> ReelConfig {
        ReelConfig(symbols: [
            ReelSymbol(identifier: "cherry",  emoji: "🍒", name: "Cherry",  weight: 9,  payout3: 4.0,  payout2: 1.0,  isWild: false, isScatter: false),
            ReelSymbol(identifier: "lemon",   emoji: "🍋", name: "Lemon",   weight: 8,  payout3: 6.0,  payout2: 0,    isWild: false, isScatter: false),
            ReelSymbol(identifier: "orange",  emoji: "🍊", name: "Orange",  weight: 6,  payout3: 10.0, payout2: 0,    isWild: false, isScatter: false),
            ReelSymbol(identifier: "grape",   emoji: "🍇", name: "Grape",   weight: 5,  payout3: 15.0, payout2: 0,    isWild: false, isScatter: false),
            ReelSymbol(identifier: "bell",    emoji: "🔔", name: "Bell",    weight: 3,  payout3: 30.0, payout2: 0,    isWild: false, isScatter: false),
            ReelSymbol(identifier: "seven",   emoji: "7️⃣", name: "Lucky 7", weight: 1,  payout3: 100.0,payout2: 0,    isWild: false, isScatter: false),
            ReelSymbol(identifier: "wild",    emoji: "⭐", name: "Wild",    weight: 2,  payout3: 0,    payout2: 0,    isWild: true,  isScatter: false),
            ReelSymbol(identifier: "scatter", emoji: "💎", name: "Scatter", weight: 2,  payout3: 0,    payout2: 0,    isWild: false, isScatter: true),
        ], scatterMinCount: 2, scatterPayout: 12.0)
    }

    static func spaceQuest() -> ReelConfig {
        ReelConfig(symbols: [
            ReelSymbol(identifier: "asteroid", emoji: "☄️", name: "Asteroid", weight: 8,  payout3: 3.0,  payout2: 0.8,  isWild: false, isScatter: false),
            ReelSymbol(identifier: "planet",   emoji: "🪐", name: "Planet",   weight: 7,  payout3: 5.0,  payout2: 0,    isWild: false, isScatter: false),
            ReelSymbol(identifier: "comet",    emoji: "🌠", name: "Comet",    weight: 5,  payout3: 8.0,  payout2: 0,    isWild: false, isScatter: false),
            ReelSymbol(identifier: "rocket",   emoji: "🚀", name: "Rocket",   weight: 4,  payout3: 14.0, payout2: 0,    isWild: false, isScatter: false),
            ReelSymbol(identifier: "star",     emoji: "🌟", name: "Star",     weight: 2,  payout3: 35.0, payout2: 0,    isWild: false, isScatter: false),
            ReelSymbol(identifier: "galaxy",   emoji: "🌌", name: "Galaxy",   weight: 1,  payout3: 120.0,payout2: 0,    isWild: false, isScatter: false),
            ReelSymbol(identifier: "ufo_wild", emoji: "🛸", name: "UFO",      weight: 3,  payout3: 0,    payout2: 0,    isWild: true,  isScatter: false),
            ReelSymbol(identifier: "blackhole",emoji: "🕳️", name: "Black Hole",weight: 2, payout3: 0,    payout2: 0,    isWild: false, isScatter: true),
        ], scatterMinCount: 2, scatterPayout: 15.0)
    }

    static func mythicRealm() -> ReelConfig {
        ReelConfig(symbols: [
            ReelSymbol(identifier: "coin",    emoji: "🪙", name: "Coin",    weight: 10, payout3: 3.0,   payout2: 1.0,  isWild: false, isScatter: false),
            ReelSymbol(identifier: "shield",  emoji: "🛡️", name: "Shield",  weight: 7,  payout3: 6.0,   payout2: 0,    isWild: false, isScatter: false),
            ReelSymbol(identifier: "sword",   emoji: "⚔️", name: "Sword",   weight: 5,  payout3: 10.0,  payout2: 0,    isWild: false, isScatter: false),
            ReelSymbol(identifier: "crown",   emoji: "👑", name: "Crown",   weight: 3,  payout3: 20.0,  payout2: 0,    isWild: false, isScatter: false),
            ReelSymbol(identifier: "dragon",  emoji: "🐉", name: "Dragon",  weight: 2,  payout3: 50.0,  payout2: 0,    isWild: false, isScatter: false),
            ReelSymbol(identifier: "phoenix", emoji: "🦅", name: "Phoenix", weight: 1,  payout3: 150.0, payout2: 0,    isWild: false, isScatter: false),
            ReelSymbol(identifier: "crystal", emoji: "🔮", name: "Crystal", weight: 3,  payout3: 0,     payout2: 0,    isWild: true,  isScatter: false),
            ReelSymbol(identifier: "rune",    emoji: "🌀", name: "Rune",    weight: 2,  payout3: 0,     payout2: 0,    isWild: false, isScatter: true),
        ], scatterMinCount: 2, scatterPayout: 18.0)
    }
}

struct ReelSpin {
    let index: Int
    let isWin: Bool
    let isBigWin: Bool
    let multiplier: Double
    let balanceAfter: Double
}

struct ReelSlotResult {
    let totalSpins: Int
    let totalWins: Int
    let bigWins: Int
    let totalPayout: Double
    let totalWagered: Double
    let rtp: Double
    let maxConsecutiveLosses: Int
    let maxConsecutiveWins: Int
    let biggestWinMultiplier: Double
    let spins: [ReelSpin]
    let balanceCurve: [Double]
    let winRateActual: Double
    let bigWinRateActual: Double
    let symbolHitCounts: [String: Int]
    let config: ReelConfig
}

struct SimPreset {
    let identifier: String
    let displayName: String
    let description: String
    let iconName: String
    let ssrRate: Double
    let srRate: Double
    let hardPity: Int
    let softPity: Int
    let pityEnabled: Bool

    static let allGachaPresets: [SimPreset] = [
        SimPreset(identifier: "genshin_style",
                  displayName: "Genshin Style",
                  description: "Low SSR rate with hard pity at 90",
                  iconName: "star.fill",
                  ssrRate: 0.006, srRate: 0.051,
                  hardPity: 90, softPity: 74, pityEnabled: true),
        SimPreset(identifier: "high_rate",
                  displayName: "High Rate",
                  description: "Generous rates for entertainment",
                  iconName: "flame.fill",
                  ssrRate: 0.05, srRate: 0.15,
                  hardPity: 50, softPity: 40, pityEnabled: true),
        SimPreset(identifier: "ultra_rare",
                  displayName: "Ultra Rare",
                  description: "Extreme low rate — test your luck",
                  iconName: "bolt.fill",
                  ssrRate: 0.003, srRate: 0.03,
                  hardPity: 120, softPity: 90, pityEnabled: true),
        SimPreset(identifier: "no_pity",
                  displayName: "No Pity",
                  description: "Pure RNG, no safety net",
                  iconName: "dice.fill",
                  ssrRate: 0.01, srRate: 0.09,
                  hardPity: 999, softPity: 999, pityEnabled: false),
    ]
}

struct ReelPreset {
    let identifier: String
    let displayName: String
    let description: String
    let iconName: String
    let winRate: Double
    let bigWinRate: Double
    let avgWinMultiplier: Double
    let maxWinMultiplier: Double

    static let allSlotPresets: [ReelPreset] = [
        ReelPreset(identifier: "low_vol",
                   displayName: "Low Volatility",
                   description: "Frequent small wins",
                   iconName: "waveform",
                   winRate: 0.40, bigWinRate: 0.01,
                   avgWinMultiplier: 1.2, maxWinMultiplier: 10),
        ReelPreset(identifier: "high_vol",
                   displayName: "High Volatility",
                   description: "Rare but massive wins",
                   iconName: "bolt.circle.fill",
                   winRate: 0.15, bigWinRate: 0.05,
                   avgWinMultiplier: 2.5, maxWinMultiplier: 100),
        ReelPreset(identifier: "standard",
                   displayName: "Standard",
                   description: "Balanced win/loss ratio",
                   iconName: "equal.circle.fill",
                   winRate: 0.25, bigWinRate: 0.03,
                   avgWinMultiplier: 1.5, maxWinMultiplier: 50),
    ]
}
