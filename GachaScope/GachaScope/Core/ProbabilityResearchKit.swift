import Foundation

enum DistributionMode: Int, CaseIterable {
    case geometric
    case binomial
    case poisson

    var title: String {
        switch self {
        case .geometric: return "Geometric"
        case .binomial: return "Binomial"
        case .poisson: return "Poisson"
        }
    }
}

enum ProbabilityResearchKit {
    static func clampProbability(_ value: Double) -> Double {
        min(max(value, 0.000001), 0.999999)
    }

    static func effectiveRate(baseRate: Double, pityEnabled: Bool, pityCounter: Int, softPity: Int, hardPity: Int, increment: Double = 0.06) -> Double {
        guard pityEnabled else { return clampProbability(baseRate) }
        if pityCounter >= hardPity { return 1 }
        guard pityCounter >= softPity else { return clampProbability(baseRate) }
        let extra = Double(max(0, pityCounter - softPity)) * increment
        return min(1, baseRate + extra)
    }

    static func firstSuccessCDF(baseRate: Double, hardPity: Int, softPity: Int, pityEnabled: Bool, increment: Double = 0.06, maxPulls: Int? = nil) -> [Double] {
        let cap = max(maxPulls ?? hardPity, 1)
        var cdf: [Double] = []
        var survive = 1.0
        for pull in 1...cap {
            let rate = effectiveRate(baseRate: baseRate, pityEnabled: pityEnabled, pityCounter: pull, softPity: softPity, hardPity: hardPity, increment: increment)
            let hit = survive * rate
            let cumulative = (cdf.last ?? 0) + hit
            cdf.append(min(1, cumulative))
            survive *= (1 - rate)
        }
        return cdf
    }

    static func firstSuccessPMF(baseRate: Double, hardPity: Int, softPity: Int, pityEnabled: Bool, increment: Double = 0.06, maxPulls: Int? = nil) -> [Double] {
        let cdf = firstSuccessCDF(baseRate: baseRate, hardPity: hardPity, softPity: softPity, pityEnabled: pityEnabled, increment: increment, maxPulls: maxPulls)
        var pmf: [Double] = []
        var prev = 0.0
        for value in cdf {
            pmf.append(max(0, value - prev))
            prev = value
        }
        return pmf
    }

    static func survivalCurve(baseRate: Double, hardPity: Int, softPity: Int, pityEnabled: Bool, increment: Double = 0.06, maxPulls: Int? = nil) -> [Double] {
        firstSuccessCDF(baseRate: baseRate, hardPity: hardPity, softPity: softPity, pityEnabled: pityEnabled, increment: increment, maxPulls: maxPulls).map { max(0, 1 - $0) }
    }

    static func expectedPulls(from pmf: [Double]) -> Double {
        pmf.enumerated().reduce(0) { partial, pair in
            partial + Double(pair.offset + 1) * pair.element
        }
    }

    static func quantiles(from cdf: [Double]) -> QuantileSummary {
        func index(for target: Double) -> Int {
            (cdf.firstIndex(where: { $0 >= target }) ?? max(cdf.count - 1, 0)) + 1
        }
        let pmf = zip(cdf, [Double](arrayLiteral: 0) + cdf.dropLast()).map { max(0, $0.0 - $0.1) }
        return QuantileSummary(
            expectedPulls: expectedPulls(from: pmf),
            p25: index(for: 0.25),
            p50: index(for: 0.50),
            p90: index(for: 0.90),
            p95: index(for: 0.95),
            p99: index(for: 0.99)
        )
    }

    static func probabilityOfAtLeastOneHit(rate: Double, draws: Int) -> Double {
        let p = clampProbability(rate)
        guard draws > 0 else { return 0 }
        return 1 - pow(1 - p, Double(draws))
    }

    static func drawsNeeded(rate: Double, targetProbability: Double) -> Int {
        let p = clampProbability(rate)
        let target = min(max(targetProbability, 0.000001), 0.999999)
        return Int(ceil(log(1 - target) / log(1 - p)))
    }

    static func geometricPMF(rate: Double, maxTrials: Int) -> [Double] {
        let p = clampProbability(rate)
        return (1...maxTrials).map { n in pow(1 - p, Double(n - 1)) * p }
    }

    static func binomialDistribution(trials: Int, rate: Double) -> [Double] {
        let p = clampProbability(rate)
        guard trials >= 0 else { return [] }
        return (0...trials).map { k in
            combination(n: trials, k: k) * pow(p, Double(k)) * pow(1 - p, Double(trials - k))
        }
    }

    static func poissonApproximation(lambda: Double, maxK: Int) -> [Double] {
        guard maxK >= 0 else { return [] }
        return (0...maxK).map { k in
            pow(lambda, Double(k)) * exp(-lambda) / factorial(k)
        }
    }

    static func quantiles(for plan: GachaPlan) -> QuantileSummary {
        let cdf = firstSuccessCDF(
            baseRate: plan.ssrRate,
            hardPity: plan.hardPity,
            softPity: plan.softPity,
            pityEnabled: plan.pityEnabled,
            increment: plan.softPityIncrement,
            maxPulls: plan.hardPity
        )
        return quantiles(from: cdf)
    }

    static func budgetPlanner(plan: GachaPlan, budget: Double, targetProbability: Double) -> BudgetPlannerResult {
        let pulls = plan.costPerPull > 0 ? Int(floor(budget / plan.costPerPull)) : 0
        let cdf = firstSuccessCDF(
            baseRate: plan.ssrRate,
            hardPity: plan.hardPity,
            softPity: plan.softPity,
            pityEnabled: plan.pityEnabled,
            increment: plan.softPityIncrement,
            maxPulls: max(plan.hardPity, pulls)
        )
        let hitProbability = pulls > 0 ? cdf[min(max(pulls - 1, 0), cdf.count - 1)] : 0
        let requiredPulls = (cdf.firstIndex(where: { $0 >= targetProbability }) ?? max(cdf.count - 1, 0)) + 1
        return BudgetPlannerResult(
            budget: budget,
            costPerPull: plan.costPerPull,
            maxPulls: pulls,
            hitProbability: hitProbability,
            requiredPullsForTarget: requiredPulls,
            requiredBudgetForTarget: Double(requiredPulls) * plan.costPerPull,
            riskBand: quantiles(from: cdf)
        )
    }

    static func compare(planA: GachaPlan, planB: GachaPlan, budget: Double) -> PlanComparisonResult {
        let plannerA = budgetPlanner(plan: planA, budget: budget, targetProbability: 0.90)
        let plannerB = budgetPlanner(plan: planB, budget: budget, targetProbability: 0.90)
        return PlanComparisonResult(
            planA: planA,
            planB: planB,
            budget: budget,
            hitRateA: plannerA.hitProbability,
            hitRateB: plannerB.hitProbability,
            expectedCostA: quantiles(for: planA).expectedPulls * planA.costPerPull,
            expectedCostB: quantiles(for: planB).expectedPulls * planB.costPerPull,
            expectedPullsA: quantiles(for: planA).expectedPulls,
            expectedPullsB: quantiles(for: planB).expectedPulls
        )
    }

    static func report(for comparison: PlanComparisonResult) -> String {
        let betterBudget = comparison.hitRateA >= comparison.hitRateB ? comparison.planA.name : comparison.planB.name
        let cheaper = comparison.expectedCostA <= comparison.expectedCostB ? comparison.planA.name : comparison.planB.name
        return """
        Research Comparison Report

        Budget: \(formatCurrency(comparison.budget))
        Plan A: \(comparison.planA.name)
        - Hit rate under budget: \(formatPercent(comparison.hitRateA))
        - Expected pulls: \(String(format: "%.1f", comparison.expectedPullsA))
        - Expected cost: \(formatCurrency(comparison.expectedCostA))

        Plan B: \(comparison.planB.name)
        - Hit rate under budget: \(formatPercent(comparison.hitRateB))
        - Expected pulls: \(String(format: "%.1f", comparison.expectedPullsB))
        - Expected cost: \(formatCurrency(comparison.expectedCostB))

        Insight:
        - Better budget efficiency: \(betterBudget)
        - Lower expected acquisition cost: \(cheaper)
        - Delta in hit rate: \(formatPercent(abs(comparison.hitRateA - comparison.hitRateB)))
        """
    }

    static func formatPercent(_ value: Double) -> String {
        String(format: "%.1f%%", value * 100)
    }

    static func formatCurrency(_ value: Double) -> String {
        String(format: "%.2f", value)
    }

    private static func combination(n: Int, k: Int) -> Double {
        guard k >= 0, n >= k else { return 0 }
        guard k != 0, k != n else { return 1 }
        let m = min(k, n - k)
        guard m > 0 else { return 1 }
        var result = 1.0
        for i in 1...m {
            result *= Double(n - m + i)
            result /= Double(i)
        }
        return result
    }

    private static func factorial(_ n: Int) -> Double {
        guard n > 1 else { return 1 }
        return (2...n).reduce(1.0) { $0 * Double($1) }
    }
}
