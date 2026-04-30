import Foundation

struct GachaPlan: Codable, Equatable {
    let id: UUID
    var name: String
    var ssrRate: Double
    var srRate: Double
    var hardPity: Int
    var softPity: Int
    var softPityIncrement: Double
    var pityEnabled: Bool
    var costPerPull: Double
    var notes: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        ssrRate: Double,
        srRate: Double,
        hardPity: Int,
        softPity: Int,
        softPityIncrement: Double = 0.06,
        pityEnabled: Bool,
        costPerPull: Double = 0,
        notes: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.ssrRate = ssrRate
        self.srRate = srRate
        self.hardPity = hardPity
        self.softPity = softPity
        self.softPityIncrement = softPityIncrement
        self.pityEnabled = pityEnabled
        self.costPerPull = costPerPull
        self.notes = notes
        self.createdAt = createdAt
    }
}

struct QuantileSummary {
    let expectedPulls: Double
    let p25: Int
    let p50: Int
    let p90: Int
    let p95: Int
    let p99: Int
}

struct BudgetPlannerResult {
    let budget: Double
    let costPerPull: Double
    let maxPulls: Int
    let hitProbability: Double
    let requiredPullsForTarget: Int
    let requiredBudgetForTarget: Double
    let riskBand: QuantileSummary
}

struct PlanComparisonResult {
    let planA: GachaPlan
    let planB: GachaPlan
    let budget: Double
    let hitRateA: Double
    let hitRateB: Double
    let expectedCostA: Double
    let expectedCostB: Double
    let expectedPullsA: Double
    let expectedPullsB: Double
}
