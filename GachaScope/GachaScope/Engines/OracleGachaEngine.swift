import Foundation

final class GachaEngine {
    static let shared = GachaEngine()
    private init() {}

    func runSimulation(
        ssrRate: Double,
        srRate: Double,
        hardPity: Int,
        softPity: Int,
        pityEnabled: Bool,
        totalPulls: Int
    ) -> GachaResult {
        var ssrCount = 0
        var srCount = 0
        var rCount = 0
        var pityCounter = 0
        var pulls: [GachaPull] = []
        var ssrIndices: [Int] = []
        var longestDrought = 0
        var currentDrought = 0
        var shortestStreak = Int.max
        var convergenceData: [(Int, Double)] = []

        for i in 0..<totalPulls {
            pityCounter += 1
            let rarity = resolveRarity(ssrRate: ssrRate, srRate: srRate,
                                       hardPity: hardPity, softPity: softPity,
                                       pityEnabled: pityEnabled, pityCounter: pityCounter)
            let pull = GachaPull(index: i + 1, rarity: rarity, pityCountAtPull: pityCounter)
            pulls.append(pull)

            switch rarity {
            case .ssr:
                ssrCount += 1
                ssrIndices.append(i + 1)
                if currentDrought > longestDrought { longestDrought = currentDrought }
                if pityCounter < shortestStreak { shortestStreak = pityCounter }
                currentDrought = 0
                pityCounter = 0
            case .sr:
                srCount += 1
                currentDrought += 1
            case .r:
                rCount += 1
                currentDrought += 1
            }

            if (i + 1) % max(1, totalPulls / 20) == 0 {
                let rate = Double(ssrCount) / Double(i + 1)
                convergenceData.append((i + 1, rate))
            }
        }
        if currentDrought > longestDrought { longestDrought = currentDrought }
        if shortestStreak == Int.max { shortestStreak = 0 }

        let avgPulls = ssrCount > 0 ? Double(totalPulls) / Double(ssrCount) : Double(totalPulls)
        let actualSSR = Double(ssrCount) / Double(totalPulls)
        let actualSR  = Double(srCount)  / Double(totalPulls)
        let luck = ssrRate > 0 ? actualSSR / ssrRate : 1.0

        return GachaResult(
            totalPulls: totalPulls,
            ssrCount: ssrCount,
            srCount: srCount,
            rCount: rCount,
            pulls: pulls,
            ssrPullIndices: ssrIndices,
            longestSSRDrought: longestDrought,
            shortestSSRStreak: shortestStreak,
            avgPullsPerSSR: avgPulls,
            actualSSRRate: actualSSR,
            actualSRRate: actualSR,
            theoreticalSSRRate: ssrRate,
            theoreticalSRRate: srRate,
            luckIndex: luck,
            badLuckIndex: longestDrought,
            convergenceData: convergenceData
        )
    }

    private func resolveRarity(ssrRate: Double, srRate: Double,
                                hardPity: Int, softPity: Int,
                                pityEnabled: Bool, pityCounter: Int) -> Rarity {
        if pityEnabled && pityCounter >= hardPity { return .ssr }

        var effectiveSSR = ssrRate
        if pityEnabled && pityCounter >= softPity {
            let extra = Double(pityCounter - softPity) * 0.06
            effectiveSSR = min(1.0, ssrRate + extra)
        }

        let roll = Double.random(in: 0..<1)
        if roll < effectiveSSR { return .ssr }
        if roll < effectiveSSR + srRate { return .sr }
        return .r
    }
}
