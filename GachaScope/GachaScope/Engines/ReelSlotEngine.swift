import Foundation

final class ReelSlotEngine {
    static let shared = ReelSlotEngine()
    private init() {}

    // MARK: - Virtual reel pool
    private func buildPool(_ config: ReelConfig) -> [ReelSymbol] {
        var pool: [ReelSymbol] = []
        for sym in config.symbols where sym.weight > 0 {
            for _ in 0..<sym.weight { pool.append(sym) }
        }
        return pool
    }

    // MARK: - Single spin
    private func spin(pool: [ReelSymbol]) -> (ReelSymbol, ReelSymbol, ReelSymbol) {
        let a = pool[Int.random(in: 0..<pool.count)]
        let b = pool[Int.random(in: 0..<pool.count)]
        let c = pool[Int.random(in: 0..<pool.count)]
        return (a, b, c)
    }

    // MARK: - Payout evaluation
    private func evaluate(s1: ReelSymbol, s2: ReelSymbol, s3: ReelSymbol,
                           config: ReelConfig) -> (payout: Double, isBig: Bool, winSym: String?) {
        let reels = [s1, s2, s3]

        // --- Scatter check: count scatters anywhere ---
        let scatterCount = reels.filter { $0.isScatter }.count
        if scatterCount >= config.scatterMinCount {
            let pay = config.scatterPayout * Double(scatterCount) / Double(config.scatterMinCount)
            return (pay, pay >= 20, "scatter")
        }

        // --- Build effective symbols, replacing wilds ---
        let nonSpecial = config.symbols.filter { !$0.isWild && !$0.isScatter }
        func effective(_ sym: ReelSymbol) -> [ReelSymbol] {
            if sym.isWild { return nonSpecial }
            return [sym]
        }

        let candidates1 = effective(s1)
        let candidates2 = effective(s2)
        let candidates3 = effective(s3)

        // Check all combinations for 3-of-a-kind
        var best: (payout: Double, id: String)? = nil
        for c1 in candidates1 {
            for c2 in candidates2 where c2.identifier == c1.identifier {
                for c3 in candidates3 where c3.identifier == c2.identifier {
                    let pay = c1.payout3
                    if pay > (best?.payout ?? 0) { best = (pay, c1.identifier) }
                }
            }
        }
        if let b = best {
            return (b.payout, b.payout >= 20, b.id)
        }

        // Check 2-of-a-kind (first two reels, any order with wilds)
        for c1 in candidates1 {
            for c2 in candidates2 where c2.identifier == c1.identifier {
                let pay = c1.payout2
                if pay > 0 { return (pay, false, c1.identifier) }
            }
        }

        return (0, false, nil)
    }

    // MARK: - Full simulation
    func runSimulation(config: ReelConfig, totalSpins: Int) -> ReelSlotResult {
        let pool = buildPool(config)
        guard !pool.isEmpty else {
            return ReelSlotResult(totalSpins: 0, totalWins: 0, bigWins: 0,
                                  totalPayout: 0, totalWagered: 0, rtp: 0,
                                  maxConsecutiveLosses: 0, maxConsecutiveWins: 0,
                                  biggestWinMultiplier: 0, spins: [], balanceCurve: [],
                                  winRateActual: 0, bigWinRateActual: 0,
                                  symbolHitCounts: [:], config: config)
        }

        var totalWins = 0
        var bigWins   = 0
        var totalPayout = 0.0
        let wager = 1.0
        var balance = 100.0
        var balanceCurve: [Double] = [balance]
        var maxConsecLoss = 0, maxConsecWin = 0
        var consecLoss = 0,    consecWin = 0
        var biggestMult = 0.0
        var symbolHits: [String: Int] = [:]
        var spins: [ReelSpin] = []
        spins.reserveCapacity(min(totalSpins, 10000))

        for i in 0..<totalSpins {
            balance -= wager
            let (r1, r2, r3) = spin(pool: pool)
            let (payout, isBig, winSym) = evaluate(s1: r1, s2: r2, s3: r3, config: config)
            let isWin = payout > 0

            if isWin {
                totalWins  += 1
                totalPayout += payout * wager
                balance     += payout * wager
                consecWin   += 1; consecLoss = 0
                if consecWin > maxConsecWin  { maxConsecWin  = consecWin  }
                if payout > biggestMult       { biggestMult   = payout     }
                if isBig { bigWins += 1 }
                if let id = winSym { symbolHits[id, default: 0] += 1 }
            } else {
                consecLoss += 1; consecWin = 0
                if consecLoss > maxConsecLoss { maxConsecLoss = consecLoss }
            }

            // Store spin — sample for memory: keep all if ≤10K, else every Nth
            let sampleStep = max(1, totalSpins / 10000)
            if totalSpins <= 10000 || (i + 1) % sampleStep == 0 {
                spins.append(ReelSpin(index: i + 1, isWin: isWin, isBigWin: isBig,
                                      multiplier: payout, balanceAfter: balance))
            }

            // Balance curve sample
            if (i + 1) % max(1, totalSpins / 100) == 0 {
                balanceCurve.append(balance)
            }
        }

        let totalWagered = Double(totalSpins) * wager
        return ReelSlotResult(
            totalSpins: totalSpins,
            totalWins: totalWins,
            bigWins: bigWins,
            totalPayout: totalPayout,
            totalWagered: totalWagered,
            rtp: totalWagered > 0 ? totalPayout / totalWagered : 0,
            maxConsecutiveLosses: maxConsecLoss,
            maxConsecutiveWins: maxConsecWin,
            biggestWinMultiplier: biggestMult,
            spins: spins,
            balanceCurve: balanceCurve,
            winRateActual: Double(totalWins) / Double(totalSpins),
            bigWinRateActual: Double(bigWins) / Double(totalSpins),
            symbolHitCounts: symbolHits,
            config: config
        )
    }
}
